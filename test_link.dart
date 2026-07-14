import 'package:supabase_flutter/supabase_flutter.dart'; void main() { final auth = Supabase.instance.client.auth; auth.linkIdentity(OAuthProvider.google); }
