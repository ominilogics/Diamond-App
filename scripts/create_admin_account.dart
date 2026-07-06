import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  print('🚀 Starting Admin Account Creation...');
  final envFile = File('.env');
  final envLines = await envFile.readAsLines();
  String? url;
  String? serviceKey;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) serviceKey = line.split('=')[1];
  }
  
  if (url == null || serviceKey == null) {
    print('❌ Missing Supabase URL or Service Role Key in .env');
    exit(1);
  }

  final client = SupabaseClient(url, serviceKey);
  final targetEmail = 'rivon.ominilogics@gmail.com';
  final targetPassword = 'minisam@omini';
  
  try {
    print('👤 Creating auth user for $targetEmail...');
    
    // Check if user already exists
    // (admin.listUsers is paginated, but let's just try to create first and catch error, or create directly)
    final res = await client.auth.admin.createUser(AdminUserAttributes(
      email: targetEmail,
      password: targetPassword,
      emailConfirm: true,
    ));
    
    final userId = res.user!.id;
    print('✅ User created with ID: $userId');

    print('🛡️ Assigning admin role...');
    await client.from('user_roles').upsert({
      'user_id': userId,
      'role': 'admin',
    });

    print('🎉 Admin account successfully created and authorized!');
    exit(0);

  } on AuthException catch (e) {
    if (e.message.contains('already has an account')) {
      print('⚠️ Account already exists. Fetching user id to ensure admin role is assigned.');
      
      // Unfortunately, getting a user by email via admin API requires iterating over listUsers()
      // Let's sign in to get the user ID since we know the password.
      // Wait, we can't sign in using the service role client without setting session.
      // We can just use the public auth client for sign in.
      
      final publicClient = SupabaseClient(url, url); // url as anon key won't work. We need anon key.
      
      // We will read anon key.
      String? anonKey;
      for (var line in envLines) {
        if (line.startsWith('SUPABASE_ANON_KEY=')) anonKey = line.split('=')[1];
      }
      
      if (anonKey != null) {
        final anonClient = SupabaseClient(url, anonKey);
        final loginRes = await anonClient.auth.signInWithPassword(email: targetEmail, password: targetPassword);
        final userId = loginRes.user!.id;
        
        await client.from('user_roles').upsert({
          'user_id': userId,
          'role': 'admin',
        });
        print('🎉 Admin role assigned to existing account!');
        exit(0);
      } else {
        print('❌ Could not fetch anon key to resolve existing user. Error: $e');
        exit(1);
      }
      
    } else {
      print('❌ Auth Error: \${e.message}');
      exit(1);
    }
  } catch (e) {
    print('❌ Unexpected Error: $e');
    exit(1);
  }
}
