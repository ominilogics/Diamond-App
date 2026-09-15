import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.6'
import { initializeApp, cert, getApps } from 'npm:firebase-admin@12.1.0/app'
import { getMessaging } from 'npm:firebase-admin@12.1.0/messaging'

const BATCH_LIMIT = 200; // Safe cap per cron run to guarantee execution under 5 seconds
const FCM_CONCURRENCY = 15; // Controlled parallel HTTP dispatch to FCM to prevent socket exhaustion

serve(async (req) => {
  console.log("🚀 [event-reminders] High-Scale Edge Function Woke Up!")
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const now = new Date().toISOString();
    console.log(`⏰ Checking for events where notification_time <= ${now} and is_notified = false (limit: ${BATCH_LIMIT})`);

    // ── 1. FETCH DUE EVENTS IN BATCH ───────────────────────────────────────────
    const { data: events, error: fetchError } = await supabaseClient
      .from('events')
      .select('id, user_id, title, notification_time')
      .eq('is_notified', false)
      .lte('notification_time', now)
      .order('notification_time', { ascending: true })
      .limit(BATCH_LIMIT);

    if (fetchError) {
      console.error("❌ Database Fetch Error:", fetchError);
      return new Response(JSON.stringify({ error: fetchError }), { status: 500 });
    }

    if (!events || events.length === 0) {
      console.log("🤷‍♂️ No pending reminders found in the database. Going back to sleep.");
      return new Response(JSON.stringify({ message: 'No pending reminders' }), { status: 200 });
    }

    console.log(`🎯 Found ${events.length} events due for notification processing.`);

    // ── 2. INITIALIZE FIREBASE ADMIN SDK (SINGLETON) ───────────────────────────
    if (getApps().length === 0) {
      console.log("⚙️ Initializing Firebase Admin SDK...");
      const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
      if (serviceAccountJson) {
         initializeApp({ credential: cert(JSON.parse(serviceAccountJson)) });
         console.log("✅ Firebase initialized successfully.");
      } else {
         console.error("❌ Missing FIREBASE_SERVICE_ACCOUNT secret!");
         return new Response(JSON.stringify({ error: 'Missing FIREBASE_SERVICE_ACCOUNT' }), { status: 500 });
      }
    }
    const messaging = getMessaging();

    // ── 3. BATCH FETCH FCM TOKENS (ELIMINATES N+1 QUERIES) ─────────────────────
    // Instead of querying user_fcm_tokens 200 times in a loop, query once for all users:
    const uniqueUserIds = [...new Set(events.map(e => e.user_id).filter(Boolean))];
    
    const { data: tokenRows, error: tokenError } = await supabaseClient
      .from('user_fcm_tokens')
      .select('token, user_id')
      .in('user_id', uniqueUserIds)
      .eq('event_reminders', true);

    if (tokenError) {
      console.error("⚠️ Failed to batch-fetch FCM tokens:", tokenError);
    }

    // Build fast O(1) in-memory lookup map: user_id -> string[] tokens
    const userTokensMap = new Map<string, string[]>();
    if (tokenRows && tokenRows.length > 0) {
      for (const row of tokenRows) {
        if (!row.token || !row.user_id) continue;
        if (!userTokensMap.has(row.user_id)) {
          userTokensMap.set(row.user_id, []);
        }
        userTokensMap.get(row.user_id)!.push(row.token);
      }
    }

    // ── 4. PREPARE NOTIFICATIONS & DISPATCH PUSHES ─────────────────────────────
    const deadTokensToPrune: string[] = [];
    const notificationsToInsert: Array<{
      user_id: string;
      title: string;
      description: string;
      is_read: boolean;
      payload: string;
    }> = [];

    // Helper: Push task runner with controlled concurrency
    type PushTask = () => Promise<void>;
    const pushTasks: PushTask[] = [];

    for (const event of events) {
      // Always prepare the in-app notification row (inbox history)
      notificationsToInsert.push({
        user_id: event.user_id,
        title: "Upcoming Event!",
        description: `Don't forget about: ${event.title}`,
        is_read: false,
        payload: '/main?tab=1'
      });

      const userTokens = userTokensMap.get(event.user_id);
      if (!userTokens || userTokens.length === 0) {
        // User has no tokens or disabled reminders; will still be marked notified & recorded in-app
        continue;
      }

      const deduplicatedTokens = [...new Set(userTokens)];

      // Queue push task
      pushTasks.push(async () => {
        try {
          const response = await messaging.sendEachForMulticast({
            tokens: deduplicatedTokens,
            notification: {
              title: "Upcoming Event!",
              body: `Don't forget about: ${event.title}`
            },
            android: {
              priority: "high"
            },
            apns: {
              headers: {
                'apns-push-type': 'alert',
                'apns-priority': '10',
              },
              payload: {
                aps: {
                  contentAvailable: true,
                  sound: "default"
                }
              }
            },
            data: {
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
              payload: '/main?tab=1',
              type: 'event reminder'
            }
          });

          response.responses.forEach((resp, idx) => {
            if (!resp.success) {
              if (
                resp.error?.code === 'messaging/invalid-registration-token' ||
                resp.error?.code === 'messaging/registration-token-not-registered'
              ) {
                deadTokensToPrune.push(deduplicatedTokens[idx]);
              }
            }
          });
        } catch (pushErr) {
          console.error(`⚠️ FCM Push error for event ${event.id}:`, pushErr);
        }
      });
    }

    // Execute FCM pushes in controlled parallel pools of 15
    console.log(`📲 Dispatching FCM pushes for ${pushTasks.length} events...`);
    for (let i = 0; i < pushTasks.length; i += FCM_CONCURRENCY) {
      const chunk = pushTasks.slice(i, i + FCM_CONCURRENCY);
      await Promise.all(chunk.map(task => task()));
    }

    // ── 5. BATCH PRUNE DEAD FCM TOKENS ─────────────────────────────────────────
    if (deadTokensToPrune.length > 0) {
      const uniqueDeadTokens = [...new Set(deadTokensToPrune)];
      console.log(`🧹 Cleaning up ${uniqueDeadTokens.length} dead/uninstalled tokens...`);
      await supabaseClient.from('user_fcm_tokens').delete().in('token', uniqueDeadTokens);
    }

    // ── 6. BATCH UPDATE EVENTS (1 SINGLE DB UPDATE QUERY) ──────────────────────
    const processedEventIds = events.map(e => e.id);
    const { error: updateError } = await supabaseClient
      .from('events')
      .update({ is_notified: true })
      .in('id', processedEventIds);

    if (updateError) {
      console.error("❌ Failed to batch update events is_notified:", updateError);
    } else {
      console.log(`✅ Marked ${processedEventIds.length} events as notified in 1 query.`);
    }

    // ── 7. BATCH INSERT IN-APP NOTIFICATIONS (1 SINGLE DB INSERT QUERY) ────────
    if (notificationsToInsert.length > 0) {
      const { error: insertError } = await supabaseClient
        .from('notifications')
        .insert(notificationsToInsert);

      if (insertError) {
        console.error("❌ Failed to batch insert in-app notifications:", insertError);
      } else {
        console.log(`✅ Saved ${notificationsToInsert.length} in-app notification records in 1 query.`);
      }
    }

    console.log(`🎉 Batch processing complete! ${events.length} events processed successfully.`);
    return new Response(
      JSON.stringify({ success: true, processed: events.length }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error("💥 CRITICAL ERROR in event-reminders:", error);
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});
