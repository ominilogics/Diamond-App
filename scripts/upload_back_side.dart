import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  print('📤 Uploading global back_side.jpg...');
  final envFile = File('.env');
  final envLines = await envFile.readAsLines();
  String? url;
  String? serviceKey;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) serviceKey = line.split('=')[1];
  }
  
  final client = SupabaseClient(url!, serviceKey!);
  final file = File('seed_data/back_side.jpg');
  
  if (await file.exists()) {
    await client.storage.from('card_assets').upload(
      'backgrounds/card_template_inside_global.jpg', 
      file, 
      fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg')
    );
    final publicUrl = client.storage.from('card_assets').getPublicUrl('backgrounds/card_template_inside_global.jpg');
    print('✅ Uploaded successfully!');
    print('🔗 Public URL: $publicUrl');
  } else {
    print('❌ File not found.');
  }
  exit(0);
}
