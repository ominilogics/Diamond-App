import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/event_entity.dart';

class LocalEventsDataSource {
  final AppDatabase db;

  LocalEventsDataSource(this.db);

  Future<List<EventTableData>> getEvents() async {
    return await db.select(db.eventsTable).get();
  }

  Future<void> saveEvent(EventsTableCompanion event) async {
    await db.into(db.eventsTable).insert(event, mode: InsertMode.replace);
  }

  Future<void> deleteEvent(int id) async {
    await db.eventsTable.deleteWhere((t) => t.id.equals(id));
  }

  Future<void> syncWithRemote(List<EventEntity> remoteEvents) async {
    await db.transaction(() async {
      for (var event in remoteEvents) {
        if (event.remoteId == null) continue;
        
        final existing = await (db.select(db.eventsTable)..where((t) => t.remoteId.equals(event.remoteId!))).getSingleOrNull();
        
        if (existing == null) {
          await db.into(db.eventsTable).insert(EventsTableCompanion.insert(
            remoteId: Value(event.remoteId),
            supabaseUserId: Value(event.supabaseUserId),
            title: event.title,
            date: event.date,
            reminder: event.reminder,
            isCustom: event.isCustom,
          ));
        } else {
          await (db.update(db.eventsTable)..where((t) => t.id.equals(existing.id))).write(
            EventsTableCompanion(
              title: Value(event.title),
              date: Value(event.date),
              reminder: Value(event.reminder),
              isCustom: Value(event.isCustom),
            ),
          );
        }
      }
    });
  }
}
