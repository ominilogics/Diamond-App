import 'package:isar/isar.dart';

part 'cart_item_model.g.dart';

@collection
class CartItemModel {
  Id id = Isar.autoIncrement;

  late String cardId;
  late String title;
  late String message;
  late DateTime addedAt;
}
