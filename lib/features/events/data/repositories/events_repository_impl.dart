import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/local_events_datasource.dart';
import '../datasources/remote_events_datasource.dart';
import '../../../../core/services/notification_service.dart';

class EventsRepositoryImpl implements EventsRepository {
  final LocalEventsDataSource dataSource;
  final RemoteEventsDataSource remoteDataSource;
  final NotificationService notificationService;

  EventsRepositoryImpl(this.dataSource, this.remoteDataSource, this.notificationService);

  @override
  Future<Either<Failure, List<EventEntity>>> getEvents() async {
    try {
      final models = await dataSource.getEvents();
      final entities = models
          .map(
            (model) => EventEntity(
              id: model.id,
              remoteId: model.remoteId,
              supabaseUserId: model.supabaseUserId,
              title: model.title,
              date: model.date,
              reminder: model.reminder,
              isCustom: model.isCustom,
            ),
          )
          .toList();
      return Either.right(entities);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to load events: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveEvent(EventEntity event) async {
    try {
      final eventWithId = (event.isCustom && event.remoteId == null) 
          ? event.copyWith(remoteId: const Uuid().v4()) 
          : event;

      final companion = EventsTableCompanion(
        id: eventWithId.id != -1 && eventWithId.id != 0 ? Value(eventWithId.id) : const Value.absent(),
        remoteId: Value(eventWithId.remoteId),
        supabaseUserId: Value(eventWithId.supabaseUserId),
        title: Value(eventWithId.title),
        date: Value(eventWithId.date),
        reminder: Value(eventWithId.reminder),
        isCustom: Value(eventWithId.isCustom),
      );

      await dataSource.saveEvent(companion);
      
      // Schedule Local Notification
      _scheduleNotification(eventWithId);

      // Silently upsert to supabase in background
      remoteDataSource.saveEvent(eventWithId).then((_) {
        debugPrint('✅ Successfully synced event SAVE to Supabase background');
      }).catchError((e) {
        debugPrint('❌ Failed to sync event SAVE to Supabase: $e');
      });

      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to save event: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(int id) async {
    try {
      final events = await dataSource.getEvents();
      final event = events.where((e) => e.id == id).firstOrNull;

      await dataSource.deleteEvent(id);
      
      // Cancel Local Notification
      if (event != null && event.remoteId != null) {
        final notificationId = event.remoteId.hashCode.abs() & 0x7FFFFFFF;
        notificationService.cancelReminder(notificationId);
      }

      if (event?.remoteId != null) {
        // Silently delete from supabase in background
        remoteDataSource.deleteEvent(event!.remoteId!).then((_) {
          debugPrint('✅ Successfully synced event DELETE to Supabase background');
        }).catchError((e) {
          debugPrint('❌ Failed to sync event DELETE to Supabase: $e');
        });
      }
      
      return Either.right(null);
    } catch (e) {
      return Either.left(DatabaseFailure('Failed to delete event: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncEvents() async {
    try {
      final remoteEvents = await remoteDataSource.getCustomEvents();
      await dataSource.syncWithRemote(remoteEvents);
      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure('Failed to sync events: $e'));
    }
  }

  void _scheduleNotification(EventEntity event) {
    if (event.remoteId == null) return;

    // -------------------------------------------------------------
    // TODO: TEMPORARY TESTING LOGIC - Fire in 10 seconds!
    // -------------------------------------------------------------
    DateTime notificationDate = DateTime.now().add(const Duration(seconds: 10));
    
    /* ORIGINAL PRODUCTION SCHEDULING LOGIC
    DateTime notificationDate = event.date;
    // Assume notification time is 9:00 AM on the target day
    notificationDate = DateTime(event.date.year, event.date.month, event.date.day, 9, 0);

    if (event.reminder == "3 Days Before") {
      notificationDate = notificationDate.subtract(const Duration(days: 3));
    } else if (event.reminder == "A Week Before") {
      notificationDate = notificationDate.subtract(const Duration(days: 7));
    } else if (event.reminder == "One Day Before") {
      notificationDate = notificationDate.subtract(const Duration(days: 1));
    }
    */

    final notificationId = event.remoteId.hashCode.abs() & 0x7FFFFFFF;

    notificationService.scheduleEventReminder(
      id: notificationId,
      title: "Upcoming Event: ${event.title}",
      body: "Don't forget, ${event.title} is coming up on ${event.date.month}/${event.date.day}!",
      scheduledDate: notificationDate,
      payload: '/events',
    );
  }
}
