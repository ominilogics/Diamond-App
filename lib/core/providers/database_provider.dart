import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in ProviderScope');
});
