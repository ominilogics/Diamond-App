import 'package:daimond/features/auth/presentation/providers/auth_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/datasources/local_events_datasource.dart';
import '../../data/datasources/remote_events_datasource.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/events_repository.dart';
import '../../../../core/services/notification_service.dart';
final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final dataSource = LocalEventsDataSource(db);
  final remoteDataSource = RemoteEventsDataSourceImpl(Supabase.instance.client);
  final notificationService = ref.watch(notificationServiceProvider);
  return EventsRepositoryImpl(dataSource, remoteDataSource, notificationService);
});

class EventsNotifier extends AsyncNotifier<List<EventEntity>> {
  @override
  Future<List<EventEntity>> build() async {
    ref.watch(authStateProvider);
    syncAndRefresh();
    return _fetchEvents();
  }

  Future<void> syncAndRefresh() async {
    final repository = ref.read(eventsRepositoryProvider);
    final result = await repository.syncEvents();
    if (!result.isLeft) {
      final updatedLocal = await _fetchEvents();
      state = AsyncValue.data(updatedLocal);
    }
  }

  Future<List<EventEntity>> _fetchEvents() async {
    final repository = ref.read(eventsRepositoryProvider);
    final result = await repository.getEvents();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (events) => events,
    );
  }

  Future<void> addEvent(EventEntity event) async {
    final repository = ref.read(eventsRepositoryProvider);
    final result = await repository.saveEvent(event);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) async {
        // Fetch strictly from local database to reflect the save instantly without racing the server
        final updatedLocal = await _fetchEvents();
        state = AsyncValue.data(updatedLocal);
      },
    );
  }

  Future<void> deleteEvent(int id) async {
    final repository = ref.read(eventsRepositoryProvider);
    final result = await repository.deleteEvent(id);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Optimistically remove from state without triggering a full server sync
        final currentEvents = state.value ?? [];
        state = AsyncValue.data(currentEvents.where((e) => e.id != id).toList());
      },
    );
  }
}

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<EventEntity>>(
  () {
    return EventsNotifier();
  },
);
