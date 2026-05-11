import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import admin from "npm:firebase-admin@12.1.1";

const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
if (!serviceAccountStr) throw new Error('Missing FIREBASE_SERVICE_ACCOUNT secret.');
const serviceAccount = JSON.parse(serviceAccountStr);

if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
}

serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseKey);

    // 1. Get the current time and adjust for West Africa Time (UTC+1)
    const now = new Date();
    now.setHours(now.getHours() + 1); 
    
    // Format as HH:mm (e.g., "08:30" or "14:00")
    const currentHour = now.getHours().toString().padStart(2, '0');
    const currentMinute = now.getMinutes().toString().padStart(2, '0');
    const currentTimeString = `${currentHour}:${currentMinute}`; 

    // 2. Find ONLY the medications scheduled for this exact minute
    // (Using .ilike just in case your local app saved it with AM/PM like "08:30 AM")
    const { data: dueMedications, error: medError } = await supabase
      .from('medications')
      .select('user_id, name, dosage, unit')
      .ilike('scheduled_time', `%${currentTimeString}%`);

    if (medError) throw medError;

    // If nobody has a pill due right now, just exit quietly!
    if (!dueMedications || dueMedications.length === 0) {
      return new Response("No medications due at this minute.", { status: 200 });
    }

    // 3. Extract the unique User IDs who need a reminder right now
    const userIds = [...new Set(dueMedications.map(m => m.user_id))];

    // 4. Fetch the specific FCM tokens for those exact users
    const { data: tokens, error: tokenError } = await supabase
      .from('user_tokens')
      .select('fcm_token')
      .in('user_id', userIds);

    if (tokenError) throw tokenError;
    if (!tokens || tokens.length === 0) return new Response("No valid tokens found.", { status: 200 });

    const fcmTokens = tokens.map(t => t.fcm_token);

    // 5. Fire the sniper shot!
    const payload = {
      notification: {
        title: "💊 Dose Reminder!",
        body: `It is time to take your medication. Open the app to log your dose.`,
      },
      tokens: fcmTokens,
    };

    const response = await admin.messaging().sendEachForMulticast(payload);

    return new Response(
      JSON.stringify({ success: true, targetedUsers: userIds.length, details: response }),
      { headers: { "Content-Type": "application/json" } }
    );

  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
});