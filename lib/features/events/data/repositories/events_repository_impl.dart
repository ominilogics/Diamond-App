import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/local_events_datasource.dart';
import '../models/event_model.dart';

class EventsRepositoryImpl implements EventsRepository {
  final LocalEventsDataSource dataSource;

  EventsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<EventEntity>>> getEvents() async {
    try {
      final models = await dataSource.getEvents();
      final entities = models.map((model) => EventEntity(
        id: model.id,
        title: model.title,
        date: model.date,
        reminder: model.reminder,
        isCustom: model.isCustom,
      )).toList();
      return Either.right(entities);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to load events: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveEvent(EventEntity event) async {
    try {
      final model = EventModel()
        ..title = event.title
        ..date = event.date
        ..reminder = event.reminder
        ..isCustom = event.isCustom;
      
      if (event.id != -1) {
        model.id = event.id;
      }
      
      await dataSource.saveEvent(model);
      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to save event: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(int id) async {
    try {
      await dataSource.deleteEvent(id);
      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to delete event: $e'));
    }
  }
}
