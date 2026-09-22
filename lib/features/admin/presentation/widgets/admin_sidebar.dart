import 'package:flutter/material.dart';
import '../admin_theme.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isDrawer;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kSidebarWidth,
      color: kSidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.diamond_outlined,
                    color: kPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rivon Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Workspace Console',
                      style: TextStyle(
                        color: kSidebarSection,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: kSidebarHoverBg, height: 1),
          const SizedBox(height: 6),

          // Categorized Navigation List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('OVERVIEW'),
                  _buildNavItem(0, Icons.dashboard_rounded, 'Overview'),

                  const SizedBox(height: 10),
                  _buildSectionHeader('CONTENT'),
                  _buildNavItem(1, Icons.category_rounded, 'Categories'),
                  _buildNavItem(2, Icons.style_rounded, 'Cards Catalog'),

                  const SizedBox(height: 10),
                  _buildSectionHeader('BUSINESS'),
                  _buildNavItem(3, Icons.payments_rounded, 'Purchases Ledger'),
                  _buildNavItem(4, Icons.auto_graph_rounded, 'Marketing Growth'),
                  _buildNavItem(5, Icons.people_rounded, 'Users Governance'),

                  const SizedBox(height: 10),
                  _buildSectionHeader('CAMPAIGNS'),
                  _buildNavItem(6, Icons.calendar_month_rounded, 'Seasonal Occasions'),
                ],
              ),
            ),
          ),

          // Bottom System Status Panel (Compact)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            decoration: BoxDecoration(
              color: kSidebarHoverBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kSidebarHoverBg),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: kSuccess,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Engine Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Rivon Enterprise v1.2',
                        style: TextStyle(
                          color: kSidebarSection,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: kSidebarSection,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  size: 17,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? kSidebarTextActive : kSidebarText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4.5,
                    height: 4.5,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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
