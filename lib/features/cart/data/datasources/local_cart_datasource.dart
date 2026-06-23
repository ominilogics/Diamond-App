import 'package:isar/isar.dart';
import '../models/cart_item_model.dart';

abstract class LocalCartDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addToCart(CartItemModel item);
  Future<void> removeFromCart(int id);
}

class LocalCartDataSourceImpl implements LocalCartDataSource {
  final Isar isar;

  LocalCartDataSourceImpl(this.isar);

  @override
  Future<List<CartItemModel>> getCartItems() async {
    return await isar.cartItemModels.where().sortByAddedAtDesc().findAll();
  }

  @override
  Future<void> addToCart(CartItemModel item) async {
    await isar.writeTxn(() async {
      await isar.cartItemModels.put(item);
    });
  }

  @override
  Future<void> removeFromCart(int id) async {
    await isar.writeTxn(() async {
      await isar.cartItemModels.delete(id);
    });
  }
}
