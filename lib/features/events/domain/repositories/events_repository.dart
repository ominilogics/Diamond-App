import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/event_entity.dart';

abstract class EventsRepository {
  Future<Either<Failure, List<EventEntity>>> getEvents();
  Future<Either<Failure, void>> saveEvent(EventEntity event);
  Future<Either<Failure, void>> deleteEvent(int id);
}
