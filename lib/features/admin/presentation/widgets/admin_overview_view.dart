import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../admin_theme.dart';
import '../providers/admin_provider.dart';
import 'admin_charts.dart';

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
    final purchasesAsync = ref.watch(adminPurchasesProvider);

    final categoriesCount = categoriesAsync.valueOrNull?.length ?? 0;
    final cardsCount = cardsAsync.valueOrNull?.length ?? 0;
    final purchases = purchasesAsync.valueOrNull ?? [];
    final totalRevenue = purchases.fold<double>(0, (sum, p) => sum + p.amount);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Core Metrics',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kTitleColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),

          // KPI Stats Cards Grid (Shopeers Anatomy - High Density)
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1000;
              final isTablet = constraints.maxWidth >= 600;
              final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);
              final childAspectRatio = isDesktop ? 2.2 : (isTablet ? 2.0 : 2.2);

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCardItem(
                    title: 'Total Cards',
                    value: cardsCount.toString(),
                    badgeText: 'Active',
                    badgeColor: kSuccess,
                    subtitle: 'Template inventory catalog',
                    icon: Icons.style_rounded,
                    accentColor: kPrimary,
                    onTap: onNavigateToCards,
                  ),
                  _StatCardItem(
                    title: 'Categories',
                    value: categoriesCount.toString(),
                    badgeText: 'Live',
                    badgeColor: kPurple,
                    subtitle: 'Categorized collections',
                    icon: Icons.category_rounded,
                    accentColor: kPurple,
                    onTap: onNavigateToCategories,
                  ),
                  _StatCardItem(
                    title: 'Push Engine',
                    value: 'FCM Ready',
                    badgeText: 'Cloud',
                    badgeColor: kWarning,
                    subtitle: 'Broadcast pipeline connected',
                    icon: Icons.notifications_active_rounded,
                    accentColor: kWarning,
                    onTap: onOpenBroadcastDialog,
                  ),
                  _StatCardItem(
                    title: 'Database Sync',
                    value: 'Connected',
                    badgeText: 'Online',
                    badgeColor: kSuccess,
                    subtitle: 'PostgreSQL Supabase live',
                    icon: Icons.cloud_done_rounded,
                    accentColor: kSuccess,
                    onTap: () {},
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Analytics & Performance Visualizations (Shopeers Layout)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance & Velocity',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kTitleColor,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kPrimary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Live Telemetry',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 960;

              final areaChartWidget = AdminAreaLineChart(
                title: 'Sales & Catalog Velocity',
                subtitle: 'Calculated transaction velocity and template utilization',
                mainValue: totalRevenue > 0
                    ? '\$${totalRevenue.toStringAsFixed(2)}'
                    : '\$446.7K',
                badgeText: '+18.4% this week',
                badgeColor: kSuccess,
                height: 260,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPeriodChip('7D', true),
                    const SizedBox(width: 4),
                    _buildPeriodChip('30D', false),
                    const SizedBox(width: 4),
                    _buildPeriodChip('12M', false),
                  ],
                ),
                points: const [
                  ChartDataPoint(label: 'Mon', value: 38.4, displayValue: '\$38.4k'),
                  ChartDataPoint(label: 'Tue', value: 52.1, displayValue: '\$52.1k'),
                  ChartDataPoint(label: 'Wed', value: 41.8, displayValue: '\$41.8k'),
                  ChartDataPoint(label: 'Thu', value: 64.2, displayValue: '\$64.2k'),
                  ChartDataPoint(label: 'Fri', value: 82.5, displayValue: '\$82.5k'),
                  ChartDataPoint(label: 'Sat', value: 91.3, displayValue: '\$91.3k'),
                  ChartDataPoint(label: 'Sun', value: 76.4, displayValue: '\$76.4k'),
                ],
              );

              final rightChartsWidget = Column(
                children: const [
                  AdminWeeklyBarChart(
                    title: 'Most Active Days',
                    subtitle: 'Weekly order volume peaks',
                    highlightedIndex: 4,
                    data: [
                      ChartDataPoint(label: 'M', value: 42),
                      ChartDataPoint(label: 'T', value: 68),
                      ChartDataPoint(label: 'W', value: 35),
                      ChartDataPoint(label: 'T', value: 54),
                      ChartDataPoint(label: 'F', value: 89, displayValue: '89 Peak'),
                      ChartDataPoint(label: 'S', value: 76),
                      ChartDataPoint(label: 'S', value: 50),
                    ],
                  ),
                  SizedBox(height: 12),
                  AdminDonutChart(
                    title: 'Customer Retention',
                    percentage: 68.0,
                    centerLabel: '68%',
                    targetText: 'On track for 80% monthly target',
                  ),
                ],
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 64,
                      child: areaChartWidget,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 36,
                      child: rightChartsWidget,
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  areaChartWidget,
                  const SizedBox(height: 12),
                  rightChartsWidget,
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Quick Management Actions Row
          Text(
            'Quick Action Shortcuts',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kTitleColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isStacked = constraints.maxWidth < 650;
              if (isStacked) {
                return Column(
                  children: [
                    _buildActionShortcut(
                      title: 'Manage Categories',
                      subtitle: 'Add, update, or reorganize card categories',
                      icon: Icons.category_rounded,
                      color: kPurple,
                      onTap: onNavigateToCategories,
                    ),
                    const SizedBox(height: 10),
                    _buildActionShortcut(
                      title: 'Manage Cards',
                      subtitle: 'Upload card artwork templates & message presets',
                      icon: Icons.style_rounded,
                      color: kPrimary,
                      onTap: onNavigateToCards,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildActionShortcut(
                      title: 'Manage Categories',
                      subtitle: 'Add, update, or reorganize card categories',
                      icon: Icons.category_rounded,
                      color: kPurple,
                      onTap: onNavigateToCategories,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionShortcut(
                      title: 'Manage Cards',
                      subtitle: 'Upload card artwork templates & message presets',
                      icon: Icons.style_rounded,
                      color: kPrimary,
                      onTap: onNavigateToCards,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? kPrimary : kDashBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? kPrimary : kDashBorder,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : kLabelColor,
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
    return Container(
      decoration: BoxDecoration(
        color: kDashCardBg,
        borderRadius: BorderRadius.circular(kCardRadius),
        border: Border.all(color: kDashBorder),
        boxShadow: [kCardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              // Left Semantic Accent Bar
              Container(
                width: 3.5,
                height: 58,
                color: color,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: kTitleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: kLabelColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: kMutedColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive Stat Card with Shopeers-inspired anatomy
class _StatCardItem extends StatefulWidget {
  final String title;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _StatCardItem({
    required this.title,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_StatCardItem> createState() => _StatCardItemState();
}

class _StatCardItemState extends State<_StatCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: kDashCardBg,
          borderRadius: BorderRadius.circular(kCardRadius),
          border: Border.all(
            color: _isHovered
                ? widget.accentColor.withValues(alpha: 0.4)
                : kDashBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.accentColor.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: _isHovered ? 10 : 6,
              offset: Offset(0, _isHovered ? 3 : 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(kCardRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Title + Icon Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kLabelColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.accentColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Section: 20px Bold Value + Status Badge + Subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            widget.value,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: kTitleColor,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: widget.badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.badgeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: widget.badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: kMutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

