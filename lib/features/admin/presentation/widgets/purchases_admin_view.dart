import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../admin_theme.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_charts.dart';

const _primaryAccent = kPrimary;
const _success = kSuccess;
const int _itemsPerPage = 15;

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

class PurchasesAdminView extends ConsumerStatefulWidget {
  const PurchasesAdminView({super.key});

  @override
  ConsumerState<PurchasesAdminView> createState() => _PurchasesAdminViewState();
}

class _PurchasesAdminViewState extends ConsumerState<PurchasesAdminView> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _activeSearchQuery = '';
  DateFilterRange _selectedDateFilter = DateFilterRange.all;
  int _currentPage = 0;
  bool _showTrendChart = true;

  List<ChartDataPoint> _computeDailyPurchasePoints(List<AdminPurchase> purchases) {
    if (purchases.isEmpty) {
      return const [
        ChartDataPoint(label: 'Mon', value: 120, displayValue: '\$120.00'),
        ChartDataPoint(label: 'Tue', value: 245, displayValue: '\$245.00'),
        ChartDataPoint(label: 'Wed', value: 190, displayValue: '\$190.00'),
        ChartDataPoint(label: 'Thu', value: 310, displayValue: '\$310.00'),
        ChartDataPoint(label: 'Fri', value: 480, displayValue: '\$480.00'),
        ChartDataPoint(label: 'Sat', value: 520, displayValue: '\$520.00'),
        ChartDataPoint(label: 'Sun', value: 390, displayValue: '\$390.00'),
      ];
    }
    final Map<String, double> dayTotals = {};
    final sorted = List<AdminPurchase>.from(purchases)
      ..sort((a, b) => a.addedAt.compareTo(b.addedAt));

    for (final p in sorted) {
      final key = '${p.addedAt.month}/${p.addedAt.day}';
      dayTotals[key] = (dayTotals[key] ?? 0) + p.amount;
    }

    if (dayTotals.length == 1) {
      final entry = dayTotals.entries.first;
      return [
        const ChartDataPoint(label: 'Start', value: 0, displayValue: '\$0.00'),
        ChartDataPoint(
          label: entry.key,
          value: entry.value,
          displayValue: '\$${entry.value.toStringAsFixed(2)}',
        ),
      ];
    }

    return dayTotals.entries.map((e) => ChartDataPoint(
      label: e.key,
      value: e.value,
      displayValue: '\$${e.value.toStringAsFixed(2)}',
    )).toList();
  }

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

  void _exportPurchasesCSV(List<AdminPurchase> purchases) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Order ID,Customer Name,Customer Email,Card Title,Amount,Delivery Method,Date',
    );
    for (final p in purchases) {
      buffer.writeln(
        '"${p.id}","${p.customerName}","${p.customerEmail}","${p.cardTitle}",\$${p.amount.toStringAsFixed(2)},"${p.deliveryMethod}","${p.addedAt.toIso8601String()}"',
      );
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Purchases CSV financial report copied to clipboard!'),
        backgroundColor: _success,
      ),
    );
  }

  void _inspectPurchaseDetail(BuildContext context, AdminPurchase purchase) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 440,
            decoration: BoxDecoration(
              color: kDashCardBg,
              borderRadius: BorderRadius.circular(kCardRadius),
              border: Border.all(color: kDashBorder),
              boxShadow: [kCardShadow],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: kDashBg,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(kCardRadius),
                      topRight: Radius.circular(kCardRadius),
                    ),
                    border: Border(
                      bottom: BorderSide(color: kDashBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _primaryAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: _primaryAccent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${purchase.id.length > 12 ? purchase.id.substring(0, 12) : purchase.id}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: kTitleColor,
                              ),
                            ),
                            Text(
                              'Customer: ${purchase.customerName}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: kLabelColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: kLabelColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Customer Email', purchase.customerEmail),
                      if (purchase.age != null) ...[
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          'Customer Age',
                          '${purchase.age} yrs (${purchase.dateOfBirth})',
                        ),
                      ],
                      const SizedBox(height: 10),
                      _buildDetailRow('Card Title', purchase.cardTitle),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        'Purchase Amount',
                        '\$${purchase.amount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        'Delivery Method',
                        purchase.deliveryMethod,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        'Timestamp',
                        '${purchase.addedAt.day}/${purchase.addedAt.month}/${purchase.addedAt.year} ${purchase.addedAt.hour.toString().padLeft(2, '0')}:${purchase.addedAt.minute.toString().padLeft(2, '0')}',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Card Inside Greeting Message',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kLabelColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kDashBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kDashBorder),
                        ),
                        child: Text(
                          purchase.message,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: kTitleColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: const BoxDecoration(
                    color: kDashBg,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(kCardRadius),
                      bottomRight: Radius.circular(kCardRadius),
                    ),
                    border: Border(top: BorderSide(color: kDashBorder)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Close', style: TextStyle(fontSize: 12.5)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: kLabelColor, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: kTitleColor,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(adminPurchasesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 750 || constraints.maxHeight < 650;

        Widget kpiBar = purchasesAsync.when(
          data: (purchases) {
            final dateFiltered = purchases
                .where((p) => _selectedDateFilter.matches(p.addedAt))
                .toList();
            final totalRevenue = dateFiltered.fold<double>(
              0,
              (sum, p) => sum + p.amount,
            );
            final uniqueBuyers = dateFiltered
                .map((p) => p.customerEmail)
                .toSet()
                .length;
            final avgOrderValue = dateFiltered.isNotEmpty
                ? totalRevenue / dateFiltered.length
                : 0.0;

            final isMobile = constraints.maxWidth < 650;
            final isTablet = constraints.maxWidth < 1000;

            if (isMobile) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Total Revenue',
                          '\$${totalRevenue.toStringAsFixed(2)}',
                          Icons.payments_rounded,
                          _success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildKpiCard(
                          'Total Orders',
                          '${dateFiltered.length}',
                          Icons.shopping_bag_rounded,
                          _primaryAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Unique Buyers',
                          '$uniqueBuyers',
                          Icons.people_alt_rounded,
                          kPurple,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildKpiCard(
                          'Avg Order',
                          '\$${avgOrderValue.toStringAsFixed(2)}',
                          Icons.trending_up_rounded,
                          kWarning,
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
                        child: _buildKpiCard(
                          'Total Revenue',
                          '\$${totalRevenue.toStringAsFixed(2)}',
                          Icons.payments_rounded,
                          _success,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKpiCard(
                          'Total Orders',
                          '${dateFiltered.length}',
                          Icons.shopping_bag_rounded,
                          _primaryAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Unique Buyers',
                          '$uniqueBuyers',
                          Icons.people_alt_rounded,
                          kPurple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKpiCard(
                          'Avg Order Value',
                          '\$${avgOrderValue.toStringAsFixed(2)}',
                          Icons.trending_up_rounded,
                          kWarning,
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
                  child: _buildKpiCard(
                    'Total Revenue',
                    '\$${totalRevenue.toStringAsFixed(2)}',
                    Icons.payments_rounded,
                    _success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'Total Orders',
                    '${dateFiltered.length}',
                    Icons.shopping_bag_rounded,
                    _primaryAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'Unique Buyers',
                    '$uniqueBuyers',
                    Icons.people_alt_rounded,
                    kPurple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'Avg Order Value',
                    '\$${avgOrderValue.toStringAsFixed(2)}',
                    Icons.trending_up_rounded,
                    kWarning,
                  ),
                ),
              ],
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: const TextStyle(fontSize: 12.5, color: kTitleColor),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Search customer or card...',
                              hintStyle: TextStyle(
                                color: kMutedColor,
                                fontSize: 12,
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
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<DateFilterRange>(
                            value: _selectedDateFilter,
                            style: const TextStyle(fontSize: 12.5, color: kTitleColor),
                            items: DateFilterRange.values.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text(d.label, style: const TextStyle(fontSize: 12.5)),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _showTrendChart = !_showTrendChart),
                    icon: Icon(
                      _showTrendChart ? Icons.visibility_off_outlined : Icons.show_chart_rounded,
                      size: 15,
                    ),
                    label: Text(_showTrendChart ? 'Hide Trend' : 'View Trend'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      side: const BorderSide(color: kDashBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          ? () => _exportPurchasesCSV(
                              purchasesAsync.valueOrNull!
                                  .where((p) => _selectedDateFilter.matches(p.addedAt))
                                  .toList(),
                            )
                          : null,
                      icon: const Icon(Icons.file_download_outlined, size: 16, color: Colors.white),
                      label: const Text(
                        'Export CSV',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
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
            final dateFiltered = purchases
                .where((p) => _selectedDateFilter.matches(p.addedAt))
                .toList();
            final filtered = dateFiltered.where((p) {
              final query = _activeSearchQuery;
              return p.customerName.toLowerCase().contains(query) ||
                  p.customerEmail.toLowerCase().contains(query) ||
                  p.cardTitle.toLowerCase().contains(query) ||
                  p.id.toLowerCase().contains(query);
            }).toList();

            if (filtered.isEmpty) {
              return Container(
                width: double.infinity,
                decoration: kCardDecoration,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 40,
                      color: kMutedColor,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No Purchases Found',
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
                : <AdminPurchase>[];

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
                                  headingRowHeight: 38,
                                  dataRowMinHeight: 46,
                                  dataRowMaxHeight: 46,
                                  headingRowColor: WidgetStateProperty.all(
                                    kDashBg,
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'ORDER ID',
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
                                        'CUSTOMER',
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
                                        'CARD TITLE',
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
                                        'AMOUNT',
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
                                        'DELIVERY METHOD',
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
                                        'PURCHASE DATE',
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
                                        'INSPECT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10.5,
                                          color: kMutedColor,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: paginatedList.map((p) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            '#${p.id.length > 8 ? p.id.substring(0, 8) : p.id}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: kLabelColor,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.customerName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: kTitleColor,
                                                ),
                                              ),
                                              Text(
                                                p.customerEmail,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: kLabelColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            p.cardTitle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.5,
                                              color: kTitleColor,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '\$${p.amount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: _success,
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
                                              p.deliveryMethod,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: kBodyColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${p.addedAt.day}/${p.addedAt.month}/${p.addedAt.year}',
                                            style: const TextStyle(
                                              color: kLabelColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.visibility_rounded,
                                                color: _primaryAccent,
                                                size: 16,
                                              ),
                                              onPressed: () =>
                                                  _inspectPurchaseDetail(context, p),
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
                        horizontal: 16,
                        vertical: 8,
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
                            'Showing ${startIndex + 1} - $endIndex of ${filtered.length} orders',
                            style: const TextStyle(
                              color: kLabelColor,
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: _currentPage > 0
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 12),
                                  side: const BorderSide(color: kDashBorder),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                child: const Text('Previous'),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Page ${_currentPage + 1} of $totalPages',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: kTitleColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: _currentPage < totalPages - 1
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 12),
                                  side: const BorderSide(color: kDashBorder),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
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
              Center(child: Text('Error loading purchases ledger: $err')),
        );

        Widget chartWidget = purchasesAsync.when(
          data: (purchases) {
            final dateFiltered = purchases
                .where((p) => _selectedDateFilter.matches(p.addedAt))
                .toList();
            final points = _computeDailyPurchasePoints(dateFiltered);
            final totalRev = dateFiltered.fold<double>(0, (s, p) => s + p.amount);

            return AdminAreaLineChart(
              title: 'Gross Transaction Flow',
              subtitle: 'Settled volume and revenue velocity across selected timeframe',
              mainValue: '\$${totalRev.toStringAsFixed(2)}',
              badgeText: '${dateFiltered.length} Settled Orders',
              badgeColor: _success,
              height: 200,
              points: points,
            );
          },
          loading: () => const SizedBox(),
          error: (_, _) => const SizedBox(),
        );

        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isNarrow ? MainAxisSize.min : MainAxisSize.max,
          children: [
            kpiBar,
            if (_showTrendChart) ...[
              const SizedBox(height: 14),
              chartWidget,
            ],
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

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
