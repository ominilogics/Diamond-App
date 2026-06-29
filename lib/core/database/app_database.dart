import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../features/favorites/data/models/favorite_table.dart';
import '../../features/orders/data/models/order_table.dart';
import '../../features/events/data/models/event_table.dart';
import '../../features/drafts/data/models/draft_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [FavoritesTable, OrdersTable, EventsTable, DraftsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(draftsTable);
        }
        if (from < 3) {
          await m.createTable(ordersTable);
        }
        if (from < 4) {
          await m.addColumn(draftsTable, draftsTable.draftName);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'daimond.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
