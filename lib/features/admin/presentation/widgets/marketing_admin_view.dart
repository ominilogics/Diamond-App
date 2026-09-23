import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../admin_theme.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';
import 'broadcast_dialog.dart';

const _primaryAccent = kPrimary;
const _success = kSuccess;
const _warning = kWarning;
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

                Widget cardsGrid;
                if (isMobile) {
                  cardsGrid = Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildCohortCard(
                              'Champions',
                              '$champions',
                              'Active VIPs',
                              Icons.star_rounded,
                              kPurple,
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
                              kMutedColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (isTablet) {
                  cardsGrid = Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildCohortCard(
                              'Champions',
                              '$champions',
                              'High spend & active',
                              Icons.star_rounded,
                              kPurple,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                      const SizedBox(height: 12),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCohortCard(
                              'Hibernating',
                              '$hibernating',
                              'Reactivation targets',
                              Icons.bedtime_rounded,
                              kMutedColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  cardsGrid = Row(
                    children: [
                      Expanded(
                        child: _buildCohortCard(
                          'Champions',
                          '$champions',
                          'High spend & active',
                          Icons.star_rounded,
                          kPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCohortCard(
                          'New Buyers',
                          '$newBuyers',
                          '1st order <14 days',
                          Icons.rocket_launch_rounded,
                          _primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCohortCard(
                          'At-Risk',
                          '$atRisk',
                          'High value, idle >45d',
                          Icons.warning_amber_rounded,
                          _warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCohortCard(
                          'Hibernating',
                          '$hibernating',
                          'Reactivation targets',
                          Icons.bedtime_rounded,
                          kMutedColor,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    cardsGrid,
                    const SizedBox(height: 12),
                    _buildCohortDistributionCard(
                      champions: champions,
                      newBuyers: newBuyers,
                      atRisk: atRisk,
                      hibernating: hibernating,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: kCardDecoration,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kDashBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kDashBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: kMutedColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: const TextStyle(fontSize: 13.5, color: kTitleColor),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Search profile...',
                              hintStyle: TextStyle(
                                color: kMutedColor,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 16,
                              color: kMutedColor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kDashBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kDashBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CustomerCohort>(
                        value: _selectedCohort,
                        style: const TextStyle(fontSize: 13.5, color: kTitleColor),
                        items: CustomerCohort.values.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c.label, style: const TextStyle(fontSize: 13.5)),
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
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kDashBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kDashBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.date_range_rounded,
                          color: kLabelColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<DateFilterRange>(
                            value: _selectedDateFilter,
                            style: const TextStyle(fontSize: 13.5, color: kTitleColor),
                            items: DateFilterRange.values.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text(d.label, style: const TextStyle(fontSize: 13.5)),
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
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => BroadcastDialog.show(context),
                    icon: const Icon(
                      Icons.campaign_rounded,
                      color: _primaryAccent,
                      size: 16,
                    ),
                    label: const Text(
                      'Push Alert',
                      style: TextStyle(
                        color: _primaryAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kDashBorder),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
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
                      onPressed: purchasesAsync.valueOrNull != null
                          ? () => _exportMetaAdsCSV(
                              _buildCustomerProfiles(purchasesAsync.valueOrNull!),
                            )
                          : null,
                      icon: const Icon(Icons.share_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        'Meta Ads CSV',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: purchasesAsync.valueOrNull != null
                        ? () => _copyMailchimpList(
                            _buildCustomerProfiles(purchasesAsync.valueOrNull!),
                          )
                        : null,
                    icon: const Icon(Icons.email_outlined, size: 16),
                    label: const Text(
                      'Copy Mailchimp',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
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
                decoration: kCardDecoration,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 40,
                      color: kMutedColor,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No Customer Profiles Match Filter',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kTitleColor,
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
              decoration: kCardDecoration,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(kCardRadius),
                        topRight: Radius.circular(kCardRadius),
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
                                  headingRowHeight: 46,
                                  dataRowMinHeight: 58,
                                  dataRowMaxHeight: 58,
                                  headingRowColor: WidgetStateProperty.all(
                                    kDashBg,
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'CUSTOMER PROFILE',
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
                                        'RFM COHORT',
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
                                        'ORDERS SENT',
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
                                        'LIFETIME SPEND',
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
                                        'RECIPIENTS REACHED',
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
                                        'LAST ACTIVE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.5,
                                          color: kMutedColor,
                                          letterSpacing: 0.9,
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
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                      color: kTitleColor,
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
                                                        color: kDashBg,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(color: kDashBorder),
                                                      ),
                                                      child: Text(
                                                        '${p.age} yrs',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: kBodyColor,
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
                                                  color: kLabelColor,
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
                                              fontSize: 13.5,
                                              color: kTitleColor,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '\$${p.totalSpent.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: _success,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${p.recipientsReached} people',
                                            style: const TextStyle(
                                              color: kLabelColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${p.lastActive.day}/${p.lastActive.month}/${p.lastActive.year}',
                                            style: const TextStyle(
                                              color: kLabelColor,
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
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: kDashBg,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(kCardRadius),
                          bottomRight: Radius.circular(kCardRadius),
                        ),
                        border: Border(
                          top: BorderSide(color: kDashBorder),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${startIndex + 1} - $endIndex of ${filtered.length} customer profiles',
                            style: const TextStyle(
                              color: kLabelColor,
                              fontSize: 13,
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: _currentPage > 0
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  minimumSize: const Size(0, 34),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Previous',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Page ${_currentPage + 1} of $totalPages',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: kTitleColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: _currentPage < totalPages - 1
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  minimumSize: const Size(0, 34),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
            const SizedBox(height: 14),
            toolbar,
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

  Widget _buildCohortDistributionCard({
    required int champions,
    required int newBuyers,
    required int atRisk,
    required int hibernating,
  }) {
    final total = champions + newBuyers + atRisk + hibernating;
    final champPct = total > 0 ? (champions / total) : 0.35;
    final newPct = total > 0 ? (newBuyers / total) : 0.28;
    final riskPct = total > 0 ? (atRisk / total) : 0.18;
    final hiberPct = total > 0 ? (hibernating / total) : 0.19;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: kCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cohort Lifecycle & Retention Flow',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTitleColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Distribution of active vs idle customers based on spending and purchase recency',
                    style: TextStyle(
                      fontSize: 12,
                      color: kMutedColor,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => BroadcastDialog.show(context),
                icon: const Icon(Icons.campaign_rounded, size: 16, color: _primaryAccent),
                label: const Text(
                  'Broadcast Campaign',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kDashBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Horizontal Segmented Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (champPct * 100).round().clamp(1, 100),
                    child: Container(color: kPurple),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (newPct * 100).round().clamp(1, 100),
                    child: Container(color: _primaryAccent),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (riskPct * 100).round().clamp(1, 100),
                    child: Container(color: _warning),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (hiberPct * 100).round().clamp(1, 100),
                    child: Container(color: kMutedColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Legend Row
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _buildLegendItem(
                'Champions',
                '${(champPct * 100).toStringAsFixed(0)}% ($champions)',
                kPurple,
              ),
              _buildLegendItem(
                'New Buyers',
                '${(newPct * 100).toStringAsFixed(0)}% ($newBuyers)',
                _primaryAccent,
              ),
              _buildLegendItem(
                'At-Risk',
                '${(riskPct * 100).toStringAsFixed(0)}% ($atRisk)',
                _warning,
              ),
              _buildLegendItem(
                'Hibernating',
                '${(hiberPct * 100).toStringAsFixed(0)}% ($hibernating)',
                kMutedColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kTitleColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: kMutedColor,
          ),
        ),
      ],
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

  Widget _buildCohortBadge(CustomerCohort cohort) {
    Color bg;
    Color fg;

    switch (cohort) {
      case CustomerCohort.champions:
        bg = kPurple.withValues(alpha: 0.12);
        fg = kPurple;
        break;
      case CustomerCohort.newBuyers:
        bg = _primaryAccent.withValues(alpha: 0.12);
        fg = _primaryAccent;
        break;
      case CustomerCohort.atRisk:
        bg = _warning.withValues(alpha: 0.12);
        fg = _warning;
        break;
      case CustomerCohort.hibernating:
        bg = kMutedColor.withValues(alpha: 0.15);
        fg = kLabelColor;
        break;
      default:
        bg = kDashBg;
        fg = kBodyColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        cohort.label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}