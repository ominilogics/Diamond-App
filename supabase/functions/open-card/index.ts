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

  // 2. Build the app's custom scheme URL for iOS / generic
  const appLink = `rivon://app/open?data=\${data}`;
  
  // Android intent URL (best for Android Chrome/in-app browsers)
  // This natively falls back to the Play Store if the app isn't installed.
  const androidIntent = `intent://app/open?data=\${data}#Intent;scheme=rivon;package=com.greetingcards.invitationmaker.rivon;end`;

  // 3. Define the fallback App Store links (Fixed Android package name)
  const playStoreLink = "https://play.google.com/store/apps/details?id=com.greetingcards.invitationmaker.rivon";
  const appStoreLink = "https://apps.apple.com/us/app/rivon/id123456789";

  // 4. Return an HTML page that attempts to open the app, with a fallback timer
  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Opening Card...</title>
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
            display: none; /* Hidden until we know it's needed */
        }
        /* Visual Debug Logs */
        #logbox {
            margin-top: 30px;
            padding: 10px;
            background-color: #1e1e1e;
            color: #4af626;
            font-family: monospace;
            font-size: 11px;
            border-radius: 4px;
            width: 90%;
            max-width: 400px;
            text-align: left;
            word-wrap: break-word;
            white-space: pre-wrap;
            max-height: 200px;
            overflow-y: auto;
        }
    </style>
</head>
<body>
    <div class="spinner" id="spinner"></div>
    <h2 id="statusTitle">Opening your card...</h2>
    
    <a href="#" id="openAppBtn" class="btn">Open App Now</a>
    
    <div id="logbox">-- SYSTEM DEBUG LOG --\\n</div>

    <script>
        function log(msg) {
            console.log(msg);
            var logbox = document.getElementById("logbox");
            logbox.innerHTML += msg + "\\n";
        }

        window.onload = function() {
            try {
                var appLink = "rivon://app/open?data=\${data}";
                var androidIntent = "intent://app/open?data=\${data}#Intent;scheme=rivon;package=com.greetingcards.invitationmaker.rivon;end";
                var playStoreLink = "\${playStoreLink}";
                var appStoreLink = "\${appStoreLink}";

                var userAgent = navigator.userAgent || navigator.vendor || window.opera;
                log("UserAgent: " + userAgent);
                
                var isAndroid = /android/i.test(userAgent);
                var isIOS = /iPad|iPhone|iPod/.test(userAgent) && !window.MSStream;
                
                log("Platform: " + (isAndroid ? "Android" : (isIOS ? "iOS" : "Other")));

                var targetUrl = isAndroid ? androidIntent : appLink;
                
                // Show button just in case
                var btn = document.getElementById("openAppBtn");
                btn.href = targetUrl;
                btn.style.display = "inline-block";
                
                log("Target DeepLink: " + targetUrl);
                
                log("Attempting redirect...");
                
                // Track if we successfully navigated away
                var hasRedirected = false;
                window.addEventListener("pagehide", function() { hasRedirected = true; log("pagehide fired"); });
                window.addEventListener("visibilitychange", function() { if(document.hidden) hasRedirected = true; });

                // Try to redirect
                window.location.href = targetUrl;
                log("Assigned window.location.href (browser handling now)");

                // Fallback Timer
                setTimeout(function() {
                    log("Fallback timer (3s) triggered.");
                    if (!hasRedirected && !document.hidden) {
                        log("Browser is still visible. Redirect failed or was blocked.");
                        log("You can try tapping the 'Open App Now' button.");
                        document.getElementById("spinner").style.display = "none";
                        document.getElementById("statusTitle").innerText = "Redirect Blocked by Browser";
                    } else {
                        log("Browser is hidden, assuming app opened successfully.");
                    }
                }, 3000);
            } catch (err) {
                log("ERROR: " + err.message);
            }
        };
    </script>
</body>
</html>
  `;

  return new Response(html, {
    status: 200,
    headers: {
      ...corsHeaders,
      "Content-Type": "text/html; charset=utf-8",
    },
  });
});
