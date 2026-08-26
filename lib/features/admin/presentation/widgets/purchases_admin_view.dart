import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';

const _primaryAccent = Color(0xFF3B82F6);
const _success = Color(0xFF10B981);
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
            width: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: _primaryAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${purchase.id}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Customer: ${purchase.customerName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Customer Email', purchase.customerEmail),
                      if (purchase.age != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Customer Age',
                          '${purchase.age} years old (${purchase.dateOfBirth})',
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildDetailRow('Card Title', purchase.cardTitle),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Purchase Amount',
                        '\$${purchase.amount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Delivery Method',
                        purchase.deliveryMethod,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Timestamp',
                        '${purchase.addedAt.day}/${purchase.addedAt.month}/${purchase.addedAt.year} ${purchase.addedAt.hour}:${purchase.addedAt.minute}',
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Card Inside Greeting Message',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          purchase.message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
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
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Close'),
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
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontSize: 14,
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
                          const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildKpiCard(
                          'Avg Order',
                          '\$${avgOrderValue.toStringAsFixed(2)}',
                          Icons.trending_up_rounded,
                          const Color(0xFFF59E0B),
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
                          const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKpiCard(
                          'Avg Order Value',
                          '\$${avgOrderValue.toStringAsFixed(2)}',
                          Icons.trending_up_rounded,
                          const Color(0xFFF59E0B),
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
                    const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'Avg Order Value',
                    '\$${avgOrderValue.toStringAsFixed(2)}',
                    Icons.trending_up_rounded,
                    const Color(0xFFF59E0B),
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
                    width: 240,
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
                        hintText: 'Search customer or card...',
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
              ElevatedButton.icon(
                onPressed: purchasesAsync.valueOrNull != null
                    ? () => _exportPurchasesCSV(
                        purchasesAsync.valueOrNull!
                            .where((p) => _selectedDateFilter.matches(p.addedAt))
                            .toList(),
                      )
                    : null,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text(
                  'Export Ledger CSV',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 56,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Purchases Found',
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
                : <AdminPurchase>[];

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
                                        'ORDER ID',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'CUSTOMER',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'CARD TITLE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'AMOUNT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'DELIVERY METHOD',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'PURCHASE DATE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'INSPECT',
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
                                          Text(
                                            '#${p.id.length > 8 ? p.id.substring(0, 8) : p.id}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF475569),
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
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                              Text(
                                                p.customerEmail,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
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
                                              fontSize: 14,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '\$${p.amount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: _success,
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
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              p.deliveryMethod,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${p.addedAt.day}/${p.addedAt.month}/${p.addedAt.year}',
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(
                                              Icons.visibility_rounded,
                                              color: _primaryAccent,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _inspectPurchaseDetail(context, p),
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
                            'Showing ${startIndex + 1} - $endIndex of ${filtered.length} orders',
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
              Center(child: Text('Error loading purchases ledger: $err')),
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

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
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
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
            ],
          ),
        ],
      ),
    );
  }
}
