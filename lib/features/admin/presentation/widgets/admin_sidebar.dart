import 'package:flutter/material.dart';

const _sidebarBg = Color(0xFF0F172A);
const _sidebarItemActiveBg = Color(0xFF1E293B);
const _sidebarText = Color(0xFF94A3B8);
const _sidebarTextActive = Colors.white;
const _primaryAccent = Color(0xFF3B82F6);

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
      width: 260,
      color: _sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.diamond_outlined,
                    color: _primaryAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Rivon Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E293B), height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSidebarItem(0, Icons.dashboard_rounded, 'Overview'),
                  _buildSidebarItem(1, Icons.category_rounded, 'Categories'),
                  _buildSidebarItem(2, Icons.style_rounded, 'Cards Catalog'),
                  _buildSidebarItem(3, Icons.payments_rounded, 'Purchases Ledger'),
                  _buildSidebarItem(4, Icons.auto_graph_rounded, 'Marketing Growth'),
                  _buildSidebarItem(5, Icons.people_rounded, 'Users Governance'),
                  _buildSidebarItem(6, Icons.calendar_month_rounded, 'Seasonal Occasions'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rivon Enterprise v1.2',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cloud Engine Active',
                  style: TextStyle(
                    color: const Color(0xFF10B981).withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _sidebarItemActiveBg : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? _primaryAccent : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? _primaryAccent : _sidebarText,
              size: 20,
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? _sidebarTextActive : _sidebarText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
