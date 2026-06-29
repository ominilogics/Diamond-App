import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart';

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
}
