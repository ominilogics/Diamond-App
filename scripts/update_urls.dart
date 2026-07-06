import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  print('🔗 Updating image URLs in the database to match the new folder name...');
  final envFile = File('.env');
  final envLines = await envFile.readAsLines();
  String? url;
  String? serviceKey;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) serviceKey = line.split('=')[1];
  }
  
  final client = SupabaseClient(url!, serviceKey!);
  
  // Fetch all cards
  final List<dynamic> cards = await client.from('cards').select();
  
  int updatedCount = 0;
  for (var card in cards) {
    String oldUrl = card['cover_image_url'];
    if (oldUrl.contains('/backgrounds/')) {
      String newUrl = oldUrl.replaceAll('/backgrounds/', '/card_images/');
      await client.from('cards').update({'cover_image_url': newUrl}).eq('id', card['id']);
      updatedCount++;
    }
  }
  
  print('✅ Successfully updated $updatedCount card URLs to point to "card_images/".');
  exit(0);
}
