import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  print('🧪 Inserting test short card into shared_cards...');
  final envFile = File('.env');
  final envLines = await envFile.readAsLines();
  String? url;
  String? anonKey;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1].trim();
    if (line.startsWith('SUPABASE_ANON_KEY=')) anonKey = line.split('=')[1].trim();
  }

  final client = SupabaseClient(url!, anonKey!);

  try {
    final testCode = 'test01';
    await client.from('shared_cards').upsert({
      'code': testCode,
      'cover_image_url': 'https://jlfgigvfmxuvlixohzli.supabase.co/storage/v1/object/public/card_assets/card_images/1783195675449_card_template_front_birthday.jpg',
      'front_message': 'Happy Birthday (Short Link Test)!',
      'inside_message': 'Wishing you an awesome day filled with joy and success! 🎂✨',
    });
    print('✅ Inserted test short card successfully!');
    print('🔗 Short Link: https://rivon-62e8a.web.app/open-card?c=$testCode');
  } catch (e) {
    print('❌ Error inserting test card: $e');
  }
  exit(0);
}
