import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../admin_theme.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';
import 'broadcast_dialog.dart';

const _primaryAccent = kPrimary;
const _success = kSuccess;

class OccasionsAdminView extends ConsumerStatefulWidget {
  const OccasionsAdminView({super.key});

  @override
  ConsumerState<OccasionsAdminView> createState() => _OccasionsAdminViewState();
}

class _OccasionsAdminViewState extends ConsumerState<OccasionsAdminView> {
  void _triggerInstantPush(AdminOccasion occasion) {
    BroadcastDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final occasionsAsync = ref.watch(adminOccasionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Campaign Banner
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 650;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kSidebarBg, kSidebarHoverBg],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(kCardRadius),
                border: Border.all(color: kDashBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: kPrimary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Seasonal Occasions Manager',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Schedule automated push notifications for upcoming holidays, anniversaries, and global events.',
                          style: TextStyle(
                            color: kMutedColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryButtonGradient,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryAccent.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => BroadcastDialog.show(context),
                              icon: const Icon(Icons.campaign_rounded, size: 16, color: Colors.white),
                              label: const Text(
                                'Broadcast Instant Alert',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    color: kPrimary,
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Seasonal Occasions Campaign Manager',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Schedule automated push notifications for upcoming holidays, anniversaries, and global events.',
                                style: TextStyle(
                                  color: kMutedColor,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryButtonGradient,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryAccent.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => BroadcastDialog.show(context),
                            icon: const Icon(Icons.campaign_rounded, size: 16, color: Colors.white),
                            label: const Text(
                              'Broadcast Instant Alert',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
        const SizedBox(height: 14),

        // Occasions Metric Overview Cards
        occasionsAsync.when(
          data: (occasions) {
            final totalOccasions = occasions.length;
            final autoPushCount = occasions.where((o) => o.autoPushEnabled).length;
            final categoriesCount =
                occasions.map((o) => o.targetCategoryName).toSet().length;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;
                final isTablet = constraints.maxWidth >= 600;

                final cards = [
                  _buildKpiCard(
                    'Scheduled Occasions',
                    '$totalOccasions',
                    'Active seasonal triggers',
                    Icons.event_available_rounded,
                    _primaryAccent,
                  ),
                  _buildKpiCard(
                    'Auto-Push Active',
                    '$autoPushCount',
                    'Pipeline scheduled',
                    Icons.notifications_active_rounded,
                    _success,
                  ),
                  _buildKpiCard(
                    'Target Categories',
                    '$categoriesCount',
                    'Direct catalog links',
                    Icons.category_rounded,
                    kPurple,
                  ),
                  _buildKpiCard(
                    'Push Pipeline',
                    'Online',
                    'Cloud Messaging Active',
                    Icons.cloud_done_rounded,
                    kWarning,
                  ),
                ];

                if (isDesktop) {
                  return Row(
                    children: cards
                        .map(
                          (c) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: c,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }
                return GridView.count(
                  crossAxisCount: isTablet ? 2 : 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: cards,
                );
              },
            );
          },
          loading: () => const SizedBox(),
          error: (_, _) => const SizedBox(),
        ),
        const SizedBox(height: 14),

        // Occasions Data Table
        Expanded(
          child: occasionsAsync.when(
            data: (occasions) {
              return Container(
                decoration: kCardDecoration,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kCardRadius),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              headingRowHeight: 38,
                              dataRowMinHeight: 46,
                              dataRowMaxHeight: 46,
                              headingRowColor: WidgetStateProperty.all(
                                kDashBg,
                              ),
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'OCCASION NAME',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.5,
                                      color: kMutedColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'EVENT DATE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.5,
                                      color: kMutedColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'TARGET CATEGORY',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.5,
                                      color: kMutedColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'AUTO-PUSH TRIGGER',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.5,
                                      color: kMutedColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'LEAD TIME',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.5,
                                      color: kMutedColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'ACTIONS',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.5,
                                      color: kMutedColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                        rows: occasions.map((occ) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.event_rounded,
                                      color: _primaryAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        occ.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: kTitleColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${occ.date.day}/${occ.date.month}/${occ.date.year}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: kTitleColor,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kDashBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: kDashBorder),
                                  ),
                                  child: Text(
                                    occ.targetCategoryName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      color: kBodyColor,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Transform.scale(
                                  scale: 0.75,
                                  child: Switch(
                                    value: occ.autoPushEnabled,
                                    activeThumbColor: _success,
                                    onChanged: (val) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Auto push reminder for ${occ.name} ${val ? 'enabled' : 'disabled'}.',
                                          ),
                                          backgroundColor: val
                                              ? _success
                                              : kMutedColor,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${occ.pushDaysBefore} days before',
                                  style: const TextStyle(
                                    color: kLabelColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () => _triggerInstantPush(occ),
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Send Alert',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: _primaryAccent),
            ),
            error: (err, stack) =>
                Center(child: Text('Error loading occasions: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: kCardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kLabelColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTitleColor,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: kMutedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
