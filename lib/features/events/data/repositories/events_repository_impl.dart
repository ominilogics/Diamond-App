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
      final calculatedNotificationTime = _calculateNotificationTime(event.date, event.reminder);
      bool newIsNotifiedState = false;

      // Rule 2: Too Late Rule
      if (calculatedNotificationTime.isBefore(DateTime.now())) {
        newIsNotifiedState = true; // Mark as already notified so it doesn't fire instantly
      } else {
        // It's in the future. Let's check if it's an edit.
        if (event.id != -1 && event.id != 0) {
          // Fetch existing event
          final existingEvents = await dataSource.getEvents();
          final existingEvent = existingEvents.where((e) => e.id == event.id).firstOrNull;
          
          if (existingEvent != null && existingEvent.notificationTime == calculatedNotificationTime) {
            // Rule 1: Time didn't change (e.g. just a title edit).
            // Senior Level Sync: Verify with Supabase if it was notified while the app was closed!
            bool serverNotified = existingEvent.isNotified;
            if (event.remoteId != null) {
              final remoteStatus = await remoteDataSource.getEventNotifiedStatus(event.remoteId!);
              if (remoteStatus != null) {
                serverNotified = remoteStatus;
              }
            }
            newIsNotifiedState = serverNotified;
          } else {
            // Rule 3: Time changed. Reset to false so it fires!
            newIsNotifiedState = false;
          }
        } else {
          // Brand new event in the future
          newIsNotifiedState = false;
        }
      }
      
      final eventWithId = (event.isCustom && event.remoteId == null) 
          ? event.copyWith(
              remoteId: const Uuid().v4(), 
              notificationTime: calculatedNotificationTime,
              isNotified: newIsNotifiedState,
            )
          : event.copyWith(
              notificationTime: calculatedNotificationTime,
              isNotified: newIsNotifiedState,
            );

      final companion = EventsTableCompanion(
        id: eventWithId.id != -1 && eventWithId.id != 0 ? Value(eventWithId.id) : const Value.absent(),
        remoteId: Value(eventWithId.remoteId),
        supabaseUserId: Value(eventWithId.supabaseUserId),
        title: Value(eventWithId.title),
        date: Value(eventWithId.date),
        reminder: Value(eventWithId.reminder),
        isCustom: Value(eventWithId.isCustom),
        notificationTime: Value(eventWithId.notificationTime),
        isNotified: Value(eventWithId.isNotified),
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

  DateTime _calculateNotificationTime(DateTime eventDate, String reminder) {
    // Assume notification time is 9:00 AM local time on the target day
    DateTime notificationDate = DateTime(eventDate.year, eventDate.month, eventDate.day, 9, 0);

    if (reminder == "3 Days Before") {
      notificationDate = notificationDate.subtract(const Duration(days: 3));
    } else if (reminder == "A Week Before") {
      notificationDate = notificationDate.subtract(const Duration(days: 7));
    } else if (reminder == "One Day Before") {
      notificationDate = notificationDate.subtract(const Duration(days: 1));
    } else if (reminder == "10 Seconds Test") {
      // For immediate testing
      return DateTime.now().add(const Duration(seconds: 10));
    }
    
    return notificationDate;
  }

  void _scheduleNotification(EventEntity event) {
    if (event.remoteId == null) return;
    // Local scheduling disabled in favor of FCM backend logic.
  }
}
