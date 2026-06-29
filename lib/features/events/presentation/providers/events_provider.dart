import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/datasources/local_events_datasource.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/events_repository.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final dataSource = LocalEventsDataSource(db);
  return EventsRepositoryImpl(dataSource);
});

class EventsNotifier extends AsyncNotifier<List<EventEntity>> {
  @override
  Future<List<EventEntity>> build() async {
    final repository = ref.watch(eventsRepositoryProvider);
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
      (_) => ref.invalidateSelf(),
    );
    await future;
  }

  Future<void> deleteEvent(int id) async {
    final repository = ref.read(eventsRepositoryProvider);
    final result = await repository.deleteEvent(id);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidateSelf(),
    );
    await future;
  }
}

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<EventEntity>>(() {
  return EventsNotifier();
});
