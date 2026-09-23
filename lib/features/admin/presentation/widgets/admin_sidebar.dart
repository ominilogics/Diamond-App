import 'package:flutter/material.dart';
import '../admin_theme.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onLogout;
  final bool isDrawer;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onLogout,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDrawer ? 280.0 : kSidebarWidth,
      color: kSidebarBg,
      child: SafeArea(
        top: isDrawer,
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo & Branding Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Image.asset(
                      'assets/icons/R_letter.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rivon Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Workspace Console',
                        style: TextStyle(
                          color: kSidebarSection,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: kSidebarHoverBg, height: 1),
            const SizedBox(height: 8),

            // Categorized Navigation List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('DASHBOARD'),
                    _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),

                    const SizedBox(height: 12),
                    _buildSectionHeader('CONTENT'),
                    _buildNavItem(1, Icons.category_rounded, 'Categories'),
                    _buildNavItem(2, Icons.style_rounded, 'Cards Catalog'),

                    const SizedBox(height: 12),
                    _buildSectionHeader('BUSINESS'),
                    _buildNavItem(3, Icons.payments_rounded, 'Purchases Ledger'),
                    _buildNavItem(4, Icons.auto_graph_rounded, 'Marketing Growth'),
                    _buildNavItem(5, Icons.people_rounded, 'Users Governance'),

                    const SizedBox(height: 12),
                    _buildSectionHeader('CAMPAIGNS'),
                    _buildNavItem(6, Icons.calendar_month_rounded, 'Seasonal Occasions'),
                  ],
                ),
              ),
            ),

            // Bottom Logout Button (Replaces Cloud Engine Active)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onLogout,
                  hoverColor: kDanger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: kSidebarHoverBg.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kSidebarHoverBg),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: kDanger,
                          size: 19,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: kSidebarSection,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onItemSelected(index),
          hoverColor: kSidebarHoverBg,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? kPrimaryGradient : null,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: kPrimary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 1.5),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? kSidebarTextActive : kSidebarText,
                  size: 19,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? kSidebarTextActive : kSidebarText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
