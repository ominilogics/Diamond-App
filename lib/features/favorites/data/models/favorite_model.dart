import 'package:isar/isar.dart';

part 'favorite_model.g.dart';

@collection
class FavoriteModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String cardId;

  late String title;
  late int colorValue;
  late String supabaseUserId;
  late DateTime favoritedAt;
}
