import 'dart:convert';
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  print('=============================================');
  print('🚀 Starting Daimond Supabase Seed Script...');
  print('=============================================');

  // 1. Load .env manually to avoid Flutter binding requirements in a pure Dart script
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('❌ ERROR: .env file not found in project root.');
    return;
  }

  final envLines = await envFile.readAsLines();
  String? url;
  String? serviceKey;

  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) serviceKey = line.split('=')[1];
  }

  if (url == null || serviceKey == null) {
    print('❌ ERROR: Please add SUPABASE_SERVICE_ROLE_KEY to your .env file to bypass RLS for seeding.');
    return;
  }

  final client = SupabaseClient(url, serviceKey);

  // 2. Read JSON Data
  final jsonFile = File('seed_data/seed_data.json');
  if (!await jsonFile.exists()) {
    print('❌ ERROR: seed_data/seed_data.json not found.');
    return;
  }

  final String jsonString = await jsonFile.readAsString();
  final Map<String, dynamic> data = jsonDecode(jsonString);
  final List<dynamic> categories = data['categories'];

  print('✅ Found ${categories.length} categories to process.\n');

  // 3. Process Each Category
  for (var catData in categories) {
    final catName = catData['name'];
    final sortOrder = catData['sort_order'];
    
    print('📦 Processing Category: $catName');

    // Insert Category
    final catResponse = await client.from('categories').insert({
      'name': catName,
      'sort_order': sortOrder,
    }).select().single();

    final String categoryId = catResponse['id'];
    
    // Process Cards for this Category
    final List<dynamic> cards = catData['cards'];
    for (var cardData in cards) {
      final String imageFilename = cardData['image_filename'];
      final File imageFile = File('seed_data/$imageFilename');

      if (!await imageFile.exists()) {
        print('   ⚠️ WARNING: Image $imageFilename not found. Skipping card.');
        continue;
      }

      print('   -> Uploading uncompressed image: $imageFilename...');
      
      // Upload to Storage (preserving 100% quality)
      final storagePath = 'backgrounds/${DateTime.now().millisecondsSinceEpoch}_$imageFilename';
      await client.storage.from('card_assets').upload(
        storagePath,
        imageFile,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );

      // Get Public URL
      final String publicUrl = client.storage.from('card_assets').getPublicUrl(storagePath);

      // Insert Card
      print('   -> Inserting card data: ${cardData['title']}');
      await client.from('cards').insert({
        'category_id': categoryId,
        'title': cardData['title'],
        'cover_image_url': publicUrl,
        'default_front_message': cardData['default_front_message'],
        'default_inside_message': cardData['default_inside_message'],
        'price': cardData['price'],
        'is_featured': cardData['is_featured'],
        'color_value': int.tryParse(cardData['color_value'].replaceAll('0x', ''), radix: 16),
      });
    }
    print('✅ Completed Category: $catName\n');
  }

  print('=============================================');
  print('🎉 SEEDING COMPLETE! Your database is ready.');
  print('=============================================');
  exit(0);
}
