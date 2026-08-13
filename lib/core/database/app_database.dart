import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
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
  int get schemaVersion => 8;

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
        if (from < 7) {
          await m.addColumn(eventsTable, eventsTable.notificationTime);
          await m.addColumn(eventsTable, eventsTable.isNotified);
        }
        if (from < 8) {
          await m.addColumn(notificationsTable, notificationsTable.payload);
        }
      },
    );
  }

  /// Clears user-specific data from local cache upon logout or account deletion.
  /// Remote structural data like categories and cards are retained to avoid redownloading gigabytes of content.
  Future<void> clearUserData() async {
    debugPrint('🗑️ [DB_CLEANUP] Starting local database wipe...');
    await transaction(() async {
      final favs = await delete(favoritesTable).go();
      debugPrint('  ├── [DB_CLEANUP] Cleared Favorites table ($favs rows)');
      final evts = await delete(eventsTable).go();
      debugPrint('  ├── [DB_CLEANUP] Cleared Events/Reminders table ($evts rows)');
      final dfts = await delete(draftsTable).go();
      debugPrint('  ├── [DB_CLEANUP] Cleared Drafts table ($dfts rows)');
      final ords = await delete(ordersTable).go();
      debugPrint('  ├── [DB_CLEANUP] Cleared Orders table ($ords rows)');
      final ntfs = await delete(notificationsTable).go();
      debugPrint('  └── [DB_CLEANUP] Cleared Notifications table ($ntfs rows)');
    });
    debugPrint('✅ [DB_CLEANUP] Local user database wipe complete.');
  }

  /// Claims anonymous data by assigning it to the newly authenticated user.
  Future<void> claimAnonymousData(String newUserId) async {
    debugPrint('[DB] Claiming anonymous data for new user: $newUserId');
    await transaction(() async {
      await (update(favoritesTable)).write(FavoritesTableCompanion(supabaseUserId: Value(newUserId)));
      await (update(eventsTable)).write(EventsTableCompanion(supabaseUserId: Value(newUserId)));
      await (update(ordersTable)).write(OrdersTableCompanion(supabaseUserId: Value(newUserId)));
      // Drafts don't have a user ID locally, so they just remain in the table
    });
  }
}
