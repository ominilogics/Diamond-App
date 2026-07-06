import 'package:drift/drift.dart';
import 'connection/shared.dart'
    if (dart.library.io) 'connection/connection_native.dart'
    if (dart.library.html) 'connection/connection_web.dart';

import '../../features/favorites/data/models/favorite_table.dart';
import '../../features/orders/data/models/order_table.dart';
import '../../features/events/data/models/event_table.dart';
import '../../features/drafts/data/models/draft_table.dart';
import '../../features/cards/data/models/remote_category_table.dart';
import '../../features/cards/data/models/remote_card_table.dart';

import '../../features/notifications/data/models/notification_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [FavoritesTable, OrdersTable, EventsTable, DraftsTable, RemoteCategoriesTable, RemoteCardsTable, NotificationsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 6;

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
        if (from < 5) {
          await m.createTable(remoteCategoriesTable);
          await m.createTable(remoteCardsTable);
        }
        if (from < 6) {
          await m.createTable(notificationsTable);
        }
      },
    );
  }
}
