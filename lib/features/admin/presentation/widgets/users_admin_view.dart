import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';

const _primaryAccent = Color(0xFF3B82F6);
const _success = Color(0xFF10B981);
const _warning = Color(0xFFF59E0B);
const _danger = Color(0xFFEF4444);
const int _itemsPerPage = 15;

class UsersAdminView extends ConsumerStatefulWidget {
  const UsersAdminView({super.key});

  @override
  ConsumerState<UsersAdminView> createState() => _UsersAdminViewState();
}

class _UsersAdminViewState extends ConsumerState<UsersAdminView> {
  final _searchController = TextEditingController();
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

  void _toggleUserBan(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.isBanned ? 'Unban Account?' : 'Ban Account?'),
          content: Text(
            user.isBanned
                ? 'Are you sure you want to reactivate access for "${user.name}"?'
                : 'Are you sure you want to ban "${user.name}"? They will lose app access immediately.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isBanned ? _success : _danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      user.isBanned
                          ? '${user.name} has been unbanned.'
                          : '${user.name} has been banned.',
                    ),
                    backgroundColor: user.isBanned ? _success : _danger,
                  ),
                );
              },
              child: Text(user.isBanned ? 'Unban' : 'Ban User'),
            ),
          ],
        );
      },
    );
  }

  void _sendPasswordResetEmail(AdminUser user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset link sent to ${user.email}'),
        backgroundColor: _primaryAccent,
      ),
    );
  }

  void _handleUserAction(BuildContext context, AdminUser user, String action) {
    if (action == 'toggle_ban') {
      _toggleUserBan(user);
    } else if (action == 'reset_password') {
      _sendPasswordResetEmail(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 750 || constraints.maxHeight < 650;

        Widget kpiBar = usersAsync.when(
          data: (users) {
            final totalUsers = users.length;
            final vipSubscribers = users
                .where((u) => u.subscriptionTier == 'VIP Subscriber')
                .length;
            final bannedAccounts = users.where((u) => u.isBanned).length;
            final ages = users.map((u) => u.age).whereType<int>().toList();
            final avgAge = ages.isNotEmpty
                ? (ages.reduce((a, b) => a + b) / ages.length).round()
                : 0;

            final isMobile = constraints.maxWidth < 650;
            final isTablet = constraints.maxWidth < 1000;

            if (isMobile) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Total Users',
                          '$totalUsers',
                          Icons.group_rounded,
                          _primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildKpiCard(
                          'VIP Subs',
                          '$vipSubscribers',
                          Icons.workspace_premium_rounded,
                          _success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Banned',
                          '$bannedAccounts',
                          Icons.block_rounded,
                          _danger,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildKpiCard(
                          'Avg Age',
                          '$avgAge yrs',
                          Icons.cake_rounded,
                          _warning,
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
                          'Total Registered Users',
                          '$totalUsers',
                          Icons.group_rounded,
                          _primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKpiCard(
                          'VIP Subscribers',
                          '$vipSubscribers',
                          Icons.workspace_premium_rounded,
                          _success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Banned Accounts',
                          '$bannedAccounts',
                          Icons.block_rounded,
                          _danger,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKpiCard(
                          'Average User Age',
                          '$avgAge yrs',
                          Icons.cake_rounded,
                          _warning,
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
                    'Total Registered Users',
                    '$totalUsers',
                    Icons.group_rounded,
                    _primaryAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'VIP Subscribers',
                    '$vipSubscribers',
                    Icons.workspace_premium_rounded,
                    _success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'Banned Accounts',
                    '$bannedAccounts',
                    Icons.block_rounded,
                    _danger,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'Average User Age',
                    '$avgAge yrs',
                    Icons.cake_rounded,
                    _warning,
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
          child: Row(
            children: [
              Expanded(
                child: Container(
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
                      hintText: 'Search user by name or email...',
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
              ),
              const SizedBox(width: 16),
              Tooltip(
                message: 'Refresh accounts directory',
                child: IconButton(
                  icon:
                      usersAsync.isLoading || usersAsync.isRefreshing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: _primaryAccent,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              color: _primaryAccent,
                            ),
                  onPressed: () => ref.invalidate(adminUsersProvider),
                ),
              ),
            ],
          ),
        );

        Widget tableWidget = usersAsync.when(
          data: (users) {
            final filtered = users.where((u) {
              final query = _activeSearchQuery;
              return u.name.toLowerCase().contains(query) ||
                  u.email.toLowerCase().contains(query) ||
                  u.id.toLowerCase().contains(query);
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
                      Icons.person_off_outlined,
                      size: 56,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No User Accounts Found',
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
                : <AdminUser>[];

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
                                    DataColumn(label: Text('USER PROFILE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                                    DataColumn(label: Text('SUBSCRIPTION TIER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                                    DataColumn(label: Text('ACCOUNT STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                                    DataColumn(label: Text('JOINED DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                                    DataColumn(label: Text('GOVERNANCE ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)))),
                                  ],
                                  rows: paginatedList.map((u) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                                  if (u.age != null) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(6)),
                                                      child: Text('${u.age} yrs', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Text(u.email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                            ],
                                          ),
                                        ),
                                        DataCell(_buildTierBadge(u.subscriptionTier)),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(color: (u.isBanned ? _danger : _success).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                            child: Text(u.isBanned ? 'Banned' : 'Active', style: TextStyle(color: u.isBanned ? _danger : _success, fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                        ),
                                        DataCell(Text('${u.createdAt.day}/${u.createdAt.month}/${u.createdAt.year}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
                                        DataCell(
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B), size: 20),
                                            onSelected: (value) => _handleUserAction(context, u, value),
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'toggle_ban',
                                                child: Row(
                                                  children: [
                                                    Icon(u.isBanned ? Icons.check_circle_outline_rounded : Icons.block_rounded, color: u.isBanned ? _success : _danger, size: 18),
                                                    const SizedBox(width: 10),
                                                    Text(u.isBanned ? 'Unban Account' : 'Ban Account'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'reset_password',
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.lock_reset_rounded, color: _primaryAccent, size: 18),
                                                    SizedBox(width: 10),
                                                    Text('Send Password Reset'),
                                                  ],
                                                ),
                                              ),
                                            ],
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
                            'Showing ${startIndex + 1} - $endIndex of ${filtered.length} users',
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
              Center(child: Text('Error loading users governance: $err')),
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

  Widget _buildTierBadge(String tier) {
    Color color;
    if (tier == 'VIP Subscriber') {
      color = const Color(0xFF8B5CF6);
    } else if (tier == 'Single-Card Buyer') {
      color = _primaryAccent;
    } else if (tier == 'Free Plan' || tier == 'Free Guest') {
      color = const Color(0xFF10B981);
    } else if (tier == 'Guest User') {
      color = const Color(0xFFF59E0B);
    } else {
      color = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tier,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
