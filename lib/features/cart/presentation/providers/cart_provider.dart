import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../data/datasources/local_cart_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final isar = ref.watch(isarProvider);
  final localDataSource = LocalCartDataSourceImpl(isar);
  return CartRepositoryImpl(localDataSource);
});

class CartNotifier extends AsyncNotifier<List<CartItemEntity>> {
  @override
  Future<List<CartItemEntity>> build() async {
    return _fetchCartItems();
  }

  Future<List<CartItemEntity>> _fetchCartItems() async {
    final repository = ref.read(cartRepositoryProvider);
    final result = await repository.getCartItems();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }

  Future<void> addToCart(CartItemEntity item) async {
    final repository = ref.read(cartRepositoryProvider);
    final result = await repository.addToCart(item);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidateSelf(),
    );
    await future;
  }

  Future<void> removeFromCart(int id) async {
    final repository = ref.read(cartRepositoryProvider);
    final result = await repository.removeFromCart(id);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidateSelf(),
    );
    await future;
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItemEntity>>(() {
  return CartNotifier();
});
