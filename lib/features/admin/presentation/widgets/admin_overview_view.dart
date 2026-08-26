import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

const _primaryAccent = Color(0xFF3B82F6);
const _success = Color(0xFF10B981);
const _warning = Color(0xFFF59E0B);
const _purple = Color(0xFF8B5CF6);

class AdminOverviewView extends ConsumerWidget {
  final VoidCallback onNavigateToCategories;
  final VoidCallback onNavigateToCards;
  final VoidCallback onOpenBroadcastDialog;

  const AdminOverviewView({
    super.key,
    required this.onNavigateToCategories,
    required this.onNavigateToCards,
    required this.onOpenBroadcastDialog,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final cardsAsync = ref.watch(adminCardsProvider);

    final categoriesCount = categoriesAsync.valueOrNull?.length ?? 0;
    final cardsCount = cardsAsync.valueOrNull?.length ?? 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Welcome Banner
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to Rivon Admin Console',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage greeting card templates, category catalog, and global push notification broadcasts in real-time.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onOpenBroadcastDialog,
                              icon: const Icon(Icons.campaign_rounded),
                              label: const Text('Broadcast Alert'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome to Rivon Admin Console',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Manage greeting card templates, category catalog, and global push notification broadcasts in real-time.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: onOpenBroadcastDialog,
                            icon: const Icon(Icons.campaign_rounded),
                            label: const Text('Broadcast Alert'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: 32),

          // KPI Stats Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1000;
              final isTablet = constraints.maxWidth >= 600;
              final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);
              final childAspectRatio = isDesktop ? 1.6 : (isTablet ? 1.8 : 2.2);

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    title: 'Total Cards',
                    value: cardsCount.toString(),
                    subtitle: 'Active template catalog',
                    icon: Icons.style_rounded,
                    color: _primaryAccent,
                    onTap: onNavigateToCards,
                  ),
                  _buildStatCard(
                    title: 'Categories',
                    value: categoriesCount.toString(),
                    subtitle: 'Catalog categories',
                    icon: Icons.category_rounded,
                    color: _purple,
                    onTap: onNavigateToCategories,
                  ),
                  _buildStatCard(
                    title: 'Push Engine',
                    value: 'FCM Ready',
                    subtitle: 'Cloud messaging active',
                    icon: Icons.notifications_active_rounded,
                    color: _warning,
                    onTap: onOpenBroadcastDialog,
                  ),
                  _buildStatCard(
                    title: 'Database Sync',
                    value: 'Connected',
                    subtitle: 'Supabase PostgreSQL',
                    icon: Icons.cloud_done_rounded,
                    color: _success,
                    onTap: () {},
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Quick Management Actions Row
          const Text(
            'Quick Action Shortcuts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionShortcut(
                  title: 'Manage Categories',
                  subtitle: 'Add, update, or reorganize card categories',
                  icon: Icons.category_rounded,
                  color: _purple,
                  onTap: onNavigateToCategories,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildActionShortcut(
                  title: 'Manage Cards',
                  subtitle: 'Upload card artwork templates & message presets',
                  icon: Icons.style_rounded,
                  color: _primaryAccent,
                  onTap: onNavigateToCards,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionShortcut({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
