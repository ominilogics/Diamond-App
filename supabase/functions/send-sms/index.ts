// @ts-nocheck
// Supabase Edge Function: send-sms
// Runtime: Deno
// Secrets required (set via Supabase Dashboard -> Settings -> Edge Functions -> Secrets):
//   TWILIO_ACCOUNT_SID  = AC51ff20604e6e5dd134ce0567f1746145
//   TWILIO_AUTH_TOKEN   = aabb3eae16543edf941436b26c7552db
//   TWILIO_FROM_NUMBER  = +17372324091

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

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
    // ── 1. Authenticate: Ensure only logged-in app users can call this ──────
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing Authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 2. Parse the request body ────────────────────────────────────────────
    const body = await req.json();
    const { toPhoneNumber, senderName, deepLinkUrl, method } = body;

    if (!toPhoneNumber || !deepLinkUrl) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: toPhoneNumber, deepLinkUrl" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 3. Read Twilio secrets from environment ──────────────────────────────
    const accountSid = Deno.env.get("TWILIO_ACCOUNT_SID");
    const authToken = Deno.env.get("TWILIO_AUTH_TOKEN");
    const fromNumber = Deno.env.get("TWILIO_FROM_NUMBER");

    if (!accountSid || !authToken || !fromNumber) {
      console.error("Missing Twilio environment secrets.");
      return new Response(
        JSON.stringify({ error: "Server configuration error." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 4. Compose the message body ──────────────────────────────────────────
    const sender = senderName?.trim() || "Someone";
    const messageBody = `Hey! ${sender} sent you a card. Open it here: ${deepLinkUrl}`;

    // ── 5. Build recipient for Twilio (WhatsApp uses "whatsapp:" prefix) ─────
    const toFormatted = method === "whatsApp"
      ? `whatsapp:${toPhoneNumber}`
      : toPhoneNumber;
    const fromFormatted = method === "whatsApp"
      ? `whatsapp:${fromNumber}`
      : fromNumber;

    // ── 6. Call the Twilio REST API ──────────────────────────────────────────
    const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`;
    const credentials = btoa(`${accountSid}:${authToken}`);

    const formData = new URLSearchParams();
    formData.append("To", toFormatted);
    formData.append("From", fromFormatted);
    formData.append("Body", messageBody);

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
      console.error("Twilio error:", twilioData);
      return new Response(
        JSON.stringify({ error: twilioData.message || "Failed to send message." }),
        { status: twilioResponse.status, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ success: true, sid: twilioData.sid }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "An unexpected server error occurred." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
