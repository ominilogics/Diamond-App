import 'package:isar/isar.dart';
import '../models/event_model.dart';

class LocalEventsDataSource {
  final Isar isar;

  LocalEventsDataSource(this.isar);

  Future<List<EventModel>> getEvents() async {
    return await isar.eventModels.where().findAll();
  }

  Future<void> saveEvent(EventModel event) async {
    await isar.writeTxn(() async {
      await isar.eventModels.put(event);
    });
  }

  Future<void> deleteEvent(int id) async {
    await isar.writeTxn(() async {
      await isar.eventModels.delete(id);
    });
  }
}
