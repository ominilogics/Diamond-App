// @ts-nocheck
// Supabase Edge Function: send-sms
// Runtime: Deno
// Required Environment Variables (Set in Supabase Dashboard -> Settings -> Edge Functions -> Secrets):
//   TWILIO_ACCOUNT_SID
//   TWILIO_AUTH_TOKEN
//   TWILIO_FROM_NUMBER
//   SUPABASE_URL
//   SUPABASE_SERVICE_ROLE_KEY

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── 1. Read Supabase Environment Variables & Setup Admin Client ─────────
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !serviceRoleKey) {
      console.error("Missing Supabase admin environment variables.");
      return new Response(
        JSON.stringify({ error: "Server configuration error." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey);

    // ── 2. Authenticate & Verify User JWT Token ─────────────────────────────
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Missing or malformed Authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const token = authHeader.replace("Bearer ", "").trim();
    const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(token);

    if (authError || !user) {
      console.error("JWT Verification failed:", authError?.message);
      return new Response(
        JSON.stringify({ error: "Unauthorized: Invalid or expired auth token." }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 3. Parse Request Body & Validate Parameters ─────────────────────────
    const body = await req.json();
    const { toPhoneNumber, senderName, deepLinkUrl, method, contentSid, contentVariables } = body;

    if (!toPhoneNumber || !deepLinkUrl) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: toPhoneNumber, deepLinkUrl" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 4. E.164 Phone Number Sanitization & Regex Validation ──────────────
    const cleanedPhone = toPhoneNumber.replace(/[\s\(\)\-\.]/g, "");
    const e164Regex = /^\+[1-9]\d{1,14}$/;

    if (!e164Regex.test(cleanedPhone)) {
      return new Response(
        JSON.stringify({ error: `Invalid phone number format '${toPhoneNumber}'. Must be international E.164 (e.g. +17372324091).` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 5. Server-Side Rate Limiting (Max 5 dispatches per user per hour) ───
    const oneHourAgo = new Date(Date.now() - 3600 * 1000).toISOString();
    const { count, error: countError } = await supabaseAdmin
      .from("sms_dispatch_logs")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id)
      .gte("created_at", oneHourAgo);

    if (!countError && count !== null && count >= 5) {
      return new Response(
        JSON.stringify({ error: "Hourly dispatch quota exceeded (max 5 per hour). Please try again later." }),
        { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 6. Read Twilio Environment Secrets ──────────────────────────────────
    const accountSid = Deno.env.get("TWILIO_ACCOUNT_SID");
    const authToken = Deno.env.get("TWILIO_AUTH_TOKEN");
    const fromNumber = Deno.env.get("TWILIO_FROM_NUMBER");

    if (!accountSid || !authToken || !fromNumber) {
      console.error("Missing Twilio environment secrets.");
      return new Response(
        JSON.stringify({ error: "Twilio server secrets missing." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 7. Compose Message / Pre-Approved Template Body ────────────────────
    const sender = senderName?.trim() || "Someone";
    const defaultMessageBody = `Your digital card from ${sender} is ready! Tap to view: ${deepLinkUrl}`;

    const isWhatsApp = method === "whatsApp";
    const toFormatted = isWhatsApp ? `whatsapp:${cleanedPhone}` : cleanedPhone;
    const fromFormatted = isWhatsApp ? `whatsapp:${fromNumber}` : fromNumber;

    // ── 8. Call Twilio REST API ─────────────────────────────────────────────
    const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`;
    const credentials = btoa(`${accountSid}:${authToken}`);

    const formData = new URLSearchParams();
    formData.append("To", toFormatted);
    formData.append("From", fromFormatted);

    // Support Twilio ContentSid / Template Variables if provided (for sandbox/template testing),
    // otherwise fallback to standard message body.
    if (contentSid) {
      formData.append("ContentSid", contentSid);
      if (contentVariables) {
        formData.append("ContentVariables", typeof contentVariables === "string" ? contentVariables : JSON.stringify(contentVariables));
      }
    } else {
      formData.append("Body", defaultMessageBody);
    }

    const twilioResponse = await fetch(twilioUrl, {
      method: "POST",
      headers: {
        "Authorization": `Basic ${credentials}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: formData.toString(),
    });

    const twilioData = await twilioResponse.json();

    if (!twilioResponse.ok) {
      console.error("Twilio API error response:", twilioData);
      return new Response(
        JSON.stringify({ error: twilioData.message || "Failed to dispatch Twilio message." }),
        { status: twilioResponse.status, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 9. Audit Log Success to Database ───────────────────────────────────
    try {
      await supabaseAdmin.from("sms_dispatch_logs").insert({
        user_id: user.id,
        recipient_phone: cleanedPhone,
        delivery_method: isWhatsApp ? "whatsApp" : "sms",
        twilio_sid: twilioData.sid,
        status: "sent",
      });
    } catch (logErr) {
      console.error("Failed to write to sms_dispatch_logs:", logErr);
    }

    return new Response(
      JSON.stringify({ success: true, sid: twilioData.sid }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Unexpected Edge Function error:", err);
    return new Response(
      JSON.stringify({ error: "An unexpected server error occurred." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
