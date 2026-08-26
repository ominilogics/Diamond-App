import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';
import 'broadcast_dialog.dart';

const _primaryAccent = Color(0xFF3B82F6);
const _success = Color(0xFF10B981);
const _warning = Color(0xFFF59E0B);
const int _itemsPerPage = 15;

enum CustomerCohort {
  all('All Customers'),
  champions('Champions'),
  newBuyers('New Buyers'),
  atRisk('At-Risk'),
  hibernating('Hibernating');

  const CustomerCohort(this.label);
  final String label;
}

enum DateFilterRange {
  all('All Time'),
  today('Today'),
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days'),
  last90Days('Last 90 Days');

  const DateFilterRange(this.label);
  final String label;

  bool matches(DateTime date) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateFilterRange.all:
        return true;
      case DateFilterRange.today:
        return date.isAfter(todayStart.subtract(const Duration(seconds: 1)));
      case DateFilterRange.last7Days:
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case DateFilterRange.last30Days:
        return date.isAfter(now.subtract(const Duration(days: 30)));
      case DateFilterRange.last90Days:
        return date.isAfter(now.subtract(const Duration(days: 90)));
    }
  }
}

class CustomerMarketingProfile {
  final String userId;
  final String name;
  final String email;
  final int? age;
  final int totalOrders;
  final double totalSpent;
  final int recipientsReached;
  final DateTime lastActive;
  final CustomerCohort cohort;

  CustomerMarketingProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.age,
    required this.totalOrders,
    required this.totalSpent,
    required this.recipientsReached,
    required this.lastActive,
    required this.cohort,
  });
}

class MarketingAdminView extends ConsumerStatefulWidget {
  const MarketingAdminView({super.key});

  @override
  ConsumerState<MarketingAdminView> createState() => _MarketingAdminViewState();
}

class _MarketingAdminViewState extends ConsumerState<MarketingAdminView> {
  final _searchController = TextEditingController();
  CustomerCohort _selectedCohort = CustomerCohort.all;
  DateFilterRange _selectedDateFilter = DateFilterRange.all;
  Timer? _debounceTimer;
  String _activeSearchQuery = '';
  int _currentPage = 0;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _activeSearchQuery = query.trim().toLowerCase();
          _currentPage = 0;
        });
      }
    });
  }

  List<CustomerMarketingProfile> _buildCustomerProfiles(
    List<AdminPurchase> purchases,
  ) {
    final Map<String, List<AdminPurchase>> grouped = {};
    for (final p in purchases) {
      grouped.putIfAbsent(p.customerEmail, () => []).add(p);
    }

    final now = DateTime.now();
    return grouped.entries.map((entry) {
      final userPurchases = entry.value;
      final email = entry.key;
      final name = userPurchases.first.customerName;
      final userId = userPurchases.first.userId;
      final totalOrders = userPurchases.length;
      final totalSpent = userPurchases.fold<double>(
        0,
        (sum, p) => sum + p.amount,
      );
      final recipientsReached = userPurchases.length * 2;
      userPurchases.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      final lastActive = userPurchases.first.addedAt;

      final daysInactive = now.difference(lastActive).inDays;

      CustomerCohort cohort;
      if (totalOrders >= 2 && totalSpent >= 10.0 && daysInactive <= 30) {
        cohort = CustomerCohort.champions;
      } else if (daysInactive <= 14 && totalOrders == 1) {
        cohort = CustomerCohort.newBuyers;
      } else if (daysInactive > 45 && totalSpent >= 10.0) {
        cohort = CustomerCohort.atRisk;
      } else {
        cohort = CustomerCohort.hibernating;
      }

      return CustomerMarketingProfile(
        userId: userId,
        name: name,
        email: email,
        age: userPurchases.first.age,
        totalOrders: totalOrders,
        totalSpent: totalSpent,
        recipientsReached: recipientsReached,
        lastActive: lastActive,
        cohort: cohort,
      );
    }).toList();
  }

  void _exportMetaAdsCSV(List<CustomerMarketingProfile> profiles) {
    final filtered = _filterProfiles(profiles);
    final buffer = StringBuffer();
    buffer.writeln('email,fn,ln');
    for (final p in filtered) {
      final parts = p.name.split(' ');
      final fn = parts.first;
      final ln = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      buffer.writeln('${p.email},$fn,$ln');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exported ${filtered.length} customer records for Meta Custom Ads Audience!',
        ),
        backgroundColor: _success,
      ),
    );
  }

  void _copyMailchimpList(List<CustomerMarketingProfile> profiles) {
    final filtered = _filterProfiles(profiles);
    final emails = filtered.map((p) => p.email).join(', ');
    Clipboard.setData(ClipboardData(text: emails));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied ${filtered.length} customer emails to clipboard!',
        ),
        backgroundColor: _primaryAccent,
      ),
    );
  }

  List<CustomerMarketingProfile> _filterProfiles(
    List<CustomerMarketingProfile> profiles,
  ) {
    return profiles.where((p) {
      final matchesCohort =
          _selectedCohort == CustomerCohort.all || p.cohort == _selectedCohort;
      final matchesDate = _selectedDateFilter.matches(p.lastActive);
      final matchesQuery =
          p.name.toLowerCase().contains(_activeSearchQuery) ||
          p.email.toLowerCase().contains(_activeSearchQuery);
      return matchesCohort && matchesDate && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(adminPurchasesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 750 || constraints.maxHeight < 650;

        Widget kpiBar = purchasesAsync.when(
          data: (purchases) {
            final profiles = _buildCustomerProfiles(purchases);
            final dateFiltered = profiles
                .where((p) => _selectedDateFilter.matches(p.lastActive))
                .toList();

            final champions = dateFiltered
                .where((p) => p.cohort == CustomerCohort.champions)
                .length;
            final newBuyers = dateFiltered
                .where((p) => p.cohort == CustomerCohort.newBuyers)
                .length;
            final atRisk = dateFiltered
                .where((p) => p.cohort == CustomerCohort.atRisk)
                .length;
            final hibernating = dateFiltered
                .where((p) => p.cohort == CustomerCohort.hibernating)
                .length;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;
                final isTablet = constraints.maxWidth < 1000;

                if (isMobile) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildCohortCard(
                              'Champions',
                              '$champions',
                              'Active VIPs',
                              Icons.star_rounded,
                              _success,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCohortCard(
                              'New Buyers',
                              '$newBuyers',
                              '<14d buyer',
                              Icons.rocket_launch_rounded,
                              _primaryAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCohortCard(
                              'At-Risk',
                              '$atRisk',
                              'Idle >45d',
                              Icons.warning_amber_rounded,
                              _warning,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCohortCard(
                              'Hibernating',
                              '$hibernating',
                              'Reactivate',
                              Icons.bedtime_rounded,
                              const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                if (isTablet) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildCohortCard(
                              'Champions',
                              '$champions',
                              'High spend & active',
                              Icons.star_rounded,
                              _success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCohortCard(
                              'New Buyers',
                              '$newBuyers',
                              '1st order <14 days',
                              Icons.rocket_launch_rounded,
                              _primaryAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCohortCard(
                              'At-Risk',
                              '$atRisk',
                              'High value, idle >45d',
                              Icons.warning_amber_rounded,
                              _warning,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCohortCard(
                              'Hibernating',
                              '$hibernating',
                              'Reactivation targets',
                              Icons.bedtime_rounded,
                              const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildCohortCard(
                        'Champions',
                        '$champions',
                        'High spend & active',
                        Icons.star_rounded,
                        _success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCohortCard(
                        'New Buyers',
                        '$newBuyers',
                        '1st order <14 days',
                        Icons.rocket_launch_rounded,
                        _primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCohortCard(
                        'At-Risk',
                        '$atRisk',
                        'High value, idle >45d',
                        Icons.warning_amber_rounded,
                        _warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCohortCard(
                        'Hibernating',
                        '$hibernating',
                        'Reactivation targets',
                        Icons.bedtime_rounded,
                        const Color(0xFF64748B),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          loading: () => const SizedBox(
            height: 90,
            child: Center(
              child: CircularProgressIndicator(color: _primaryAccent),
            ),
          ),
          error: (_, _) => const SizedBox(),
        );

        Widget toolbar = Container(
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
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        hintText: 'Search profile...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: Color(0xFF94A3B8),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CustomerCohort>(
                        value: _selectedCohort,
                        items: CustomerCohort.values.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCohort = val;
                              _currentPage = 0;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.date_range_rounded,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<DateFilterRange>(
                            value: _selectedDateFilter,
                            items: DateFilterRange.values.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text(d.label),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedDateFilter = val;
                                  _currentPage = 0;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => BroadcastDialog.show(context),
                    icon: const Icon(
                      Icons.campaign_rounded,
                      color: _primaryAccent,
                      size: 18,
                    ),
                    label: const Text(
                      'Targeted Push Alert',
                      style: TextStyle(
                        color: _primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: purchasesAsync.valueOrNull != null
                        ? () => _exportMetaAdsCSV(
                            _buildCustomerProfiles(purchasesAsync.valueOrNull!),
                          )
                        : null,
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text(
                      'Export Meta Ads CSV',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: purchasesAsync.valueOrNull != null
                        ? () => _copyMailchimpList(
                            _buildCustomerProfiles(purchasesAsync.valueOrNull!),
                          )
                        : null,
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: const Text(
                      'Copy Mailchimp List',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        Widget tableWidget = purchasesAsync.when(
          data: (purchases) {
            final profiles = _buildCustomerProfiles(purchases);
            final filtered = _filterProfiles(profiles);

            if (filtered.isEmpty) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 56,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Customer Profiles Match Filter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              );
            }

            final totalPages = (filtered.length / _itemsPerPage).ceil();
            if (totalPages > 0 && _currentPage >= totalPages) {
              _currentPage = totalPages - 1;
            }
            if (_currentPage < 0) {
              _currentPage = 0;
            }
            final startIndex = _currentPage * _itemsPerPage;
            final endIndex = (startIndex + _itemsPerPage < filtered.length)
                ? startIndex + _itemsPerPage
                : filtered.length;
            final paginatedList =
                (startIndex <= endIndex && startIndex < filtered.length)
                ? filtered.sublist(startIndex, endIndex)
                : <CustomerMarketingProfile>[];

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
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: constraints.maxWidth),
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
                                        'CUSTOMER PROFILE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'RFM COHORT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'ORDERS SENT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'LIFETIME SPEND',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'RECIPIENTS REACHED',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'LAST ACTIVE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: paginatedList.map((p) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    p.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  if (p.age != null) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFE2E8F0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '${p.age} yrs',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(0xFF334155),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Text(
                                                p.email,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(_buildCohortBadge(p.cohort)),
                                        DataCell(
                                          Text(
                                            '${p.totalOrders} cards',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '\$${p.totalSpent.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: _success,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${p.recipientsReached} people',
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${p.lastActive.day}/${p.lastActive.month}/${p.lastActive.year}',
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 13,
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
                  ),

                  // Pagination Footer
                  if (totalPages > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${startIndex + 1} - $endIndex of ${filtered.length} customer profiles',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: _currentPage > 0
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                child: const Text('Previous'),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Page ${_currentPage + 1} of $totalPages',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: _currentPage < totalPages - 1
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                child: const Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: _primaryAccent),
          ),
          error: (err, stack) =>
              Center(child: Text('Error loading customer analytics: $err')),
        );

        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isNarrow ? MainAxisSize.min : MainAxisSize.max,
          children: [
            kpiBar,
            const SizedBox(height: 24),
            toolbar,
            const SizedBox(height: 24),
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

  Widget _buildCohortCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCohortBadge(CustomerCohort cohort) {
    Color bg;
    Color fg;

    switch (cohort) {
      case CustomerCohort.champions:
        bg = _success.withValues(alpha: 0.1);
        fg = _success;
        break;
      case CustomerCohort.newBuyers:
        bg = _primaryAccent.withValues(alpha: 0.1);
        fg = _primaryAccent;
        break;
      case CustomerCohort.atRisk:
        bg = _warning.withValues(alpha: 0.1);
        fg = _warning;
        break;
      case CustomerCohort.hibernating:
        bg = const Color(0xFF64748B).withValues(alpha: 0.1);
        fg = const Color(0xFF64748B);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF0F172A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        cohort.label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
