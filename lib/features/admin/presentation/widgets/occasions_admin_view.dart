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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 750 || constraints.maxHeight < 650;

        // Occasions Metric Overview Cards
        final metricOverview = occasionsAsync.when(
          data: (occasions) {
            final totalOccasions = occasions.length;
            final autoPushCount = occasions.where((o) => o.autoPushEnabled).length;
            final categoriesCount =
                occasions.map((o) => o.targetCategoryName).toSet().length;

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

            final isDesktop = constraints.maxWidth >= 900;
            final isTablet = constraints.maxWidth >= 600;

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
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isTablet ? 2.5 : 3.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: cards,
            );
          },
          loading: () => const SizedBox(),
          error: (_, _) => const SizedBox(),
        );

        // Occasions Data Table
        final tableWidget = occasionsAsync.when(
          data: (occasions) {
            return Container(
              decoration: kCardDecoration,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kCardRadius),
                child: LayoutBuilder(
                  builder: (context, tableConstraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: tableConstraints.maxWidth,
                          ),
                          child: DataTable(
                            headingRowHeight: 46,
                            dataRowMinHeight: 58,
                            dataRowMaxHeight: 58,
                            headingRowColor: WidgetStateProperty.all(
                              kDashBg,
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'OCCASION NAME',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                    color: kMutedColor,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'EVENT DATE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                    color: kMutedColor,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'TARGET CATEGORY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                    color: kMutedColor,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'AUTO-PUSH TRIGGER',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                    color: kMutedColor,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'LEAD TIME',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                    color: kMutedColor,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'ACTIONS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                    color: kMutedColor,
                                    letterSpacing: 0.9,
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
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: _primaryAccent.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.event_rounded,
                                            color: _primaryAccent,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            occ.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
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
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kDashBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: kDashBorder),
                                      ),
                                      child: Text(
                                        occ.targetCategoryName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: kBodyColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Transform.scale(
                                      scale: 0.82,
                                      child: Switch(
                                        value: occ.autoPushEnabled,
                                        activeThumbColor: _primaryAccent,
                                        activeTrackColor: _primaryAccent.withValues(alpha: 0.38),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        onChanged: (val) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Auto push reminder for ${occ.name} ${val ? 'enabled' : 'disabled'}.',
                                              ),
                                              backgroundColor: val
                                                  ? _primaryAccent
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
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    ElevatedButton.icon(
                                      onPressed: () => _triggerInstantPush(occ),
                                      icon: const Icon(
                                        Icons.send_rounded,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Send Alert',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primaryAccent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        minimumSize: const Size(0, 34),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
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
        );

        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isNarrow ? MainAxisSize.min : MainAxisSize.max,
          children: [
            metricOverview,
            const SizedBox(height: 14),
            isNarrow
                ? SizedBox(height: 520, child: tableWidget)
                : Expanded(child: tableWidget),
          ],
        );

        if (isNarrow) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: body,
          );
        }

        return body;
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: kCardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kTitleColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: kMutedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
