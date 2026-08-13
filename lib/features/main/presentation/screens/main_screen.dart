import 'package:daimond/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/routing/app_routes.dart';

import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../features/events/presentation/screens/events_screen.dart';
import '../../../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainScreen extends HookConsumerWidget {
  final int? initialTabIndex;
  const MainScreen({super.key, this.initialTabIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      if (initialTabIndex != null) {
        Future.microtask(() => ref.read(bottomNavIndexProvider.notifier).state = initialTabIndex!);
      }
      return null;
    }, [initialTabIndex]);

    final currentIndex = ref.watch(bottomNavIndexProvider);

    final pages = [
      const HomeScreen(),
      const EventsScreen(),
      const FavoritesScreen(),
      const SettingsScreen(),
    ];

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ref.read(bottomNavIndexProvider.notifier).state = 0;
          context.go('/main?tab=0');
        }
      },
      child: GradientScaffold(
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
            // Keep GoRouter's URL in sync so deep linking and parameters don't get stuck
            context.go('/main?tab=$index');
          },
        ),
        body: IndexedStack(index: currentIndex, children: pages),
      ),
    );
  }
}
