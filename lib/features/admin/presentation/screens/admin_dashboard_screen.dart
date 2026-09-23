import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../admin_theme.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_overview_view.dart';
import '../widgets/categories_admin_view.dart';
import '../widgets/cards_admin_view.dart';
import '../widgets/purchases_admin_view.dart';
import '../widgets/marketing_admin_view.dart';
import '../widgets/users_admin_view.dart';
import '../widgets/occasions_admin_view.dart';
import '../widgets/broadcast_dialog.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;
  String? _activeCategoryFilterId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String get _currentTabTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Categories Management';
      case 2:
        return 'Cards Management';
      case 3:
        return 'Purchases & Financial Ledger';
      case 4:
        return 'Marketing & Growth Engine';
      case 5:
        return 'Users & Account Governance';
      case 6:
        return 'Seasonal Occasions';
      default:
        return 'Admin Console';
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return buildAdminDialog(
          context: dialogContext,
          title: 'Sign Out',
          icon: Icons.logout_rounded,
          iconColor: kDanger,
          width: 440,
          content: const Text(
            'Are you sure you want to sign out of the Rivon Admin workspace?',
            style: TextStyle(
              fontSize: 13.5,
              color: kBodyColor,
              height: 1.5,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                minimumSize: const Size(0, 36),
                side: const BorderSide(color: kDashBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kDanger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                minimumSize: const Size(0, 36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ref.read(authProvider.notifier).signOut();
                if (mounted) {
                  context.goNamed(AppRoute.login.name);
                }
              },
              child: const Text('Confirm Sign Out', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Theme(
      data: buildAdminTheme(context),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: kDashBg,
      drawer: isDesktop
          ? null
          : Drawer(
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
                onLogout: () {
                  Navigator.pop(context);
                  _handleLogout();
                },
                isDrawer: true,
              ),
            ),
      body: Row(
        children: [
          // Desktop Fixed Sidebar
          if (isDesktop)
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              onLogout: _handleLogout,
            ),

          // Main Screen Content Area
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                Container(
                  height: kTopBarHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? kPagePadding : 16,
                  ),
                  decoration: BoxDecoration(
                    color: kDashCardBg,
                    border: const Border(
                      bottom: BorderSide(color: kDashBorder, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (!isDesktop) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.menu_rounded,
                                  color: kTitleColor,
                                ),
                                onPressed: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                _currentTabTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isDesktop ? 17 : 15,
                                  fontWeight: FontWeight.w700,
                                  color: kTitleColor,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Top Bar Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Broadcast Alert Action Button (App Signature Gradient)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: kPrimaryGradient,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimary.withValues(alpha: 0.28),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1.5),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => BroadcastDialog.show(context),
                              icon: const Icon(Icons.campaign_rounded, size: 16),
                              label: isDesktop
                                  ? const Text('Broadcast Alert')
                                  : const Text('Broadcast'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 13 : 10,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Notification Bell (Compact)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: kDashBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kDashBorder),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: kLabelColor,
                                size: 17,
                              ),
                              onPressed: () => BroadcastDialog.show(context),
                              tooltip: 'System Broadcasts',
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Profile Chip (Compact)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: kDashBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: kDashBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    gradient: kPrimaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                                if (isDesktop) ...[
                                  const SizedBox(width: 7),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Admin Console',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.5,
                                          color: kTitleColor,
                                        ),
                                      ),
                                      Text(
                                        'Superadmin',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 9.5,
                                          color: kMutedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 3),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Cached Tab Stack
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? kPagePadding : 16.0),
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        AdminOverviewView(
                          onNavigateToCategories: () =>
                              setState(() => _selectedIndex = 1),
                          onNavigateToCards: () =>
                              setState(() => _selectedIndex = 2),
                          onOpenBroadcastDialog: () =>
                              BroadcastDialog.show(context),
                        ),
                        CategoriesAdminView(
                          onSelectCategoryFilter: (catId) {
                            setState(() {
                              _activeCategoryFilterId = catId;
                              _selectedIndex = 2;
                            });
                          },
                        ),
                        CardsAdminView(
                          initialCategoryId: _activeCategoryFilterId,
                        ),
                        const PurchasesAdminView(),
                        const MarketingAdminView(),
                        const UsersAdminView(),
                        const OccasionsAdminView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

