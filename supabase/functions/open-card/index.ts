// @ts-nocheck
// Supabase Edge Function: open-card
// Runtime: Deno
// Purpose: Serves as a clickable link in SMS/WhatsApp that redirects to the app's custom scheme.
// If the app is not installed, it falls back to the App Store or Play Store.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve((req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // 1. Get the payload from the URL query params
  const url = new URL(req.url);
  const data = url.searchParams.get("data") || "";

  // 2. Build the app's custom scheme URL
  const appLink = `rivon://open?data=${data}`;

  // 3. Define the fallback App Store links
  const playStoreLink = "https://play.google.com/store/apps/details?id=com.diamond.app";
  const appStoreLink = "https://apps.apple.com/us/app/rivon/id123456789"; // Replace with actual Apple ID

  // 4. Return an HTML page that attempts to open the app, with a fallback timer
  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Opening Rivon Card...</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #f8f9fa;
            color: #333;
            text-align: center;
            padding: 20px;
        }
        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #3498db;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .btn {
            margin-top: 20px;
            padding: 12px 24px;
            background-color: #007aff;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="spinner"></div>
    <h2>Opening your card...</h2>
    <p>If the app doesn't open automatically, tap below.</p>
    <a href="${appLink}" class="btn">Open App</a>

    <script>
        // Attempt to open the app via custom scheme
        window.location.href = "${appLink}";

        // If the app doesn't open, redirect to the app store after 2.5 seconds
        setTimeout(function() {
            var userAgent = navigator.userAgent || navigator.vendor || window.opera;
            if (/android/i.test(userAgent)) {
                window.location.href = "${playStoreLink}";
            } else if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
                window.location.href = "${appStoreLink}";
            } else {
                // Desktop or unknown: Just show a message
                document.body.innerHTML = "<h2>Please open this link on your mobile phone to view your card.</h2>";
            }
        }, 2500);
    </script>
</body>
</html>
  `;

  return new Response(html, {
    status: 200,
    headers: {
      ...corsHeaders,
      "Content-Type": "text/html",
    },
  });
});
