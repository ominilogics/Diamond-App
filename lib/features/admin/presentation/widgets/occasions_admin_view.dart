import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';
import 'broadcast_dialog.dart';

const _primaryAccent = Color(0xFF3B82F6);
const _success = Color(0xFF10B981);

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
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
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
                              color: Color(0xFF60A5FA),
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Seasonal Occasions Manager',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Schedule automated push notifications for upcoming holidays, anniversaries, and global events.',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => BroadcastDialog.show(context),
                            icon: const Icon(Icons.campaign_rounded, size: 20),
                            label: const Text(
                              'Broadcast Instant Alert',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
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
                                    color: Color(0xFF60A5FA),
                                    size: 28,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Seasonal Occasions Campaign Manager',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Schedule automated push notifications for upcoming holidays, anniversaries, and global events.',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => BroadcastDialog.show(context),
                          icon: const Icon(Icons.campaign_rounded, size: 20),
                          label: const Text(
                            'Broadcast Instant Alert',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Occasions Data Table
        Expanded(
          child: occasionsAsync.when(
            data: (occasions) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                        headingRowHeight: 52,
                        dataRowMinHeight: 64,
                        dataRowMaxHeight: 64,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF8FAFC),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'OCCASION NAME',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'EVENT DATE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'TARGET CATEGORY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'AUTO-PUSH TRIGGER',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'LEAD TIME',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'ACTIONS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF475569),
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
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        occ.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF0F172A),
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
                                    color: Color(0xFF1E293B),
                                    fontSize: 14,
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
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    occ.targetCategoryName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Switch(
                                  value: occ.autoPushEnabled,
                                  activeColor: _success,
                                  onChanged: (val) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Auto push reminder for ${occ.name} ${val ? 'enabled' : 'disabled'}.',
                                        ),
                                        backgroundColor: val
                                            ? _success
                                            : const Color(0xFF64748B),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${occ.pushDaysBefore} days before',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () => _triggerInstantPush(occ),
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'Send Alert Now',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
}
