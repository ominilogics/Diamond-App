import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/admin_sidebar.dart';
import '../widgets/admin_overview_view.dart';
import '../widgets/categories_admin_view.dart';
import '../widgets/cards_admin_view.dart';
import '../widgets/purchases_admin_view.dart';
import '../widgets/marketing_admin_view.dart';
import '../widgets/users_admin_view.dart';
import '../widgets/occasions_admin_view.dart';
import '../widgets/broadcast_dialog.dart';

const _bg = Color(0xFFF1F5F9);
const _cardBg = Colors.white;
const _primaryAccent = Color(0xFF3B82F6);

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
        return 'Dashboard Overview';
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
        return 'Seasonal Occasions Campaign Manager';
      default:
        return 'Admin Console';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _bg,
      drawer: isDesktop
          ? null
          : Drawer(
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
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
            ),

          // Main Screen Content Area
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
                  decoration: const BoxDecoration(
                    color: _cardBg,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
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
                                  color: Color(0xFF0F172A),
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
                                  fontSize: isDesktop ? 20 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: _primaryAccent,
                            child: Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                          if (isDesktop) ...[
                            const SizedBox(width: 10),
                            const Text(
                              'Admin Console',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Cached Tab Stack
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
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
    );
  }
}
