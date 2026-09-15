import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.6'
import { initializeApp, cert, getApps } from 'npm:firebase-admin@12.1.0/app'
import { getMessaging } from 'npm:firebase-admin@12.1.0/messaging'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const payload = await req.json()
    // Extract 'type' from the flutter request
    const { userId, title, body, broadcast, type } = payload

    if (!title || !body) {
      return new Response(JSON.stringify({ error: 'Missing title or body' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    if (!userId && !broadcast) {
      return new Response(JSON.stringify({ error: 'Missing userId or broadcast flag' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    let fcmTokens: string[] = []
    let userIdsToNotify: string[] = []

    if (broadcast === true) {
      let query = supabaseClient.from('user_fcm_tokens').select('token, user_id');
      
      if (type === 'special offer') {
        query = query.eq('special_offers', true);
      } else if (type === 'new card') {
        query = query.eq('new_card_alerts', true);
      } else if (type === 'event reminder') {
        query = query.eq('event_reminders', true);
      }

      const { data, error } = await query;

      if (error || !data || data.length === 0) {
        return new Response(JSON.stringify({ error: 'No subscribed FCM tokens found for this category' }), { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
      }
      fcmTokens = [...new Set(data.map(row => row.token))]
      userIdsToNotify = [...new Set(data.map(row => row.user_id))].filter(Boolean)
    } else {
      const { data, error } = await supabaseClient.from('user_fcm_tokens').select('token, user_id').eq('user_id', userId).single()
      if (error || !data) {
        return new Response(JSON.stringify({ error: 'User FCM token not found' }), { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
      }
      fcmTokens = [data.token]
      userIdsToNotify = [data.user_id]
    }

    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
    if (!serviceAccountJson) {
       return new Response(JSON.stringify({ error: 'FIREBASE_SERVICE_ACCOUNT environment variable is missing in Supabase!' }), { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    if (getApps().length === 0) {
      initializeApp({
        credential: cert(JSON.parse(serviceAccountJson))
      })
    }

    // 🟢 DYNAMIC PAYLOAD RESOLVER
    // Accurately maps the admin's 'type' directly to the Flutter route!
    let resolvedPayload = '/notifications'; // Fallback
    if (type === 'special offer') {
      resolvedPayload = '/subscription';
    } else if (type === 'new card') {
      resolvedPayload = '/cards';
    } else if (type === 'event reminder') {
      resolvedPayload = '/main?tab=1';
    }

    const messaging = getMessaging()
    
    // 🟢 CRITICAL FIX: FCM Multicast hard limit is 500 tokens per call.
    // Chunk tokens into batches of 500 so broadcasts with 501+ devices do not crash.
    const CHUNK_SIZE = 500;
    let totalSuccessCount = 0;
    let totalFailureCount = 0;

    for (let i = 0; i < fcmTokens.length; i += CHUNK_SIZE) {
      const tokenChunk = fcmTokens.slice(i, i + CHUNK_SIZE);
      const message = {
        notification: { title, body },
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
          payload: resolvedPayload, // 🟢 Inserted here for Background/Killed State FCM routing
          type: type || 'default' 
        },
        tokens: tokenChunk 
      }

      const response = await messaging.sendEachForMulticast(message)
      totalSuccessCount += response.successCount;
      totalFailureCount += response.failureCount;
    }

    // Insert in-app notifications in safe batches of 500
    if (userIdsToNotify.length > 0) {
      const notificationsToInsert = userIdsToNotify.map(uid => ({
        user_id: uid,
        title: title,
        description: body,
        is_read: false,
        payload: resolvedPayload // 🟢 Inserted here for In-App UI routing
      }));
      
      for (let i = 0; i < notificationsToInsert.length; i += CHUNK_SIZE) {
        const batch = notificationsToInsert.slice(i, i + CHUNK_SIZE);
        const { error: insertError } = await supabaseClient.from('notifications').insert(batch);
        if (insertError) {
          console.error("❌ Failed to insert notifications batch into database:", insertError);
        }
      }
      console.log(`✅ Successfully processed ${notificationsToInsert.length} notifications for the database.`);
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: `Successfully sent to ${totalSuccessCount} devices. Failed: ${totalFailureCount}`, 
        successCount: totalSuccessCount,
        failureCount: totalFailureCount,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'Internal Server Error', details: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
