import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order_entity.dart';

abstract class RemoteOrderDataSource {
  Future<List<OrderEntity>> getOrders();
  Future<void> addOrder(OrderEntity order);
  Future<void> removeOrder(String remoteId);
}

class RemoteOrderDataSourceImpl implements RemoteOrderDataSource {
  final SupabaseClient supabaseClient;

  RemoteOrderDataSourceImpl(this.supabaseClient);

  @override
  Future<List<OrderEntity>> getOrders() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('orders')
        .select()
        .eq('user_id', userId);

    return (response as List).map((data) => OrderEntity(
      id: 0, 
      remoteId: data['id'],
      supabaseUserId: data['user_id'],
      cardId: data['card_id'],
      title: data['title'],
      message: data['message'],
      addedAt: DateTime.parse(data['added_at']),
    )).toList();
  }

  @override
  Future<void> addOrder(OrderEntity order) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await supabaseClient.from('orders').insert({
      if (order.remoteId != null) 'id': order.remoteId,
      'user_id': userId,
      'card_id': order.cardId,
      'title': order.title,
      'message': order.message,
      'added_at': order.addedAt.toIso8601String(),
    });
  }

  @override
  Future<void> removeOrder(String remoteId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await supabaseClient
        .from('orders')
        .delete()
        .match({'id': remoteId, 'user_id': userId});
  }
}
