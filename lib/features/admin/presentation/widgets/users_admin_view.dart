import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../admin_theme.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';

const _primaryAccent = kPrimary;
const _success = kSuccess;
const _warning = kWarning;
const _danger = kDanger;
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
        return buildAdminDialog(
          context: context,
          title: user.isBanned ? 'Reactivate Account' : 'Suspend Account',
          icon: user.isBanned ? Icons.check_circle_outline_rounded : Icons.block_rounded,
          iconColor: user.isBanned ? _success : _danger,
          width: 420,
          content: Text(
            user.isBanned
                ? 'Are you sure you want to restore application access for "${user.name}"? They will regain access to their cards and account immediately.'
                : 'Are you sure you want to suspend "${user.name}"? They will lose access to the app immediately.',
            style: const TextStyle(
              fontSize: 13,
              color: kBodyColor,
              height: 1.45,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                side: const BorderSide(color: kDashBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 12.5)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isBanned ? _success : _danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
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
              child: Text(
                user.isBanned ? 'Confirm Reactivation' : 'Confirm Suspension',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
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
                          kPurple,
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiCard(
                          'VIP Subscribers',
                          '$vipSubscribers',
                          Icons.workspace_premium_rounded,
                          kPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                      const SizedBox(width: 12),
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
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    'VIP Subscribers',
                    '$vipSubscribers',
                    Icons.workspace_premium_rounded,
                    kPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    'Banned Accounts',
                    '$bannedAccounts',
                    Icons.block_rounded,
                    _danger,
                  ),
                ),
                const SizedBox(width: 12),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: kCardDecoration,
          child: Row(
            children: [
              Expanded(
                child: Container(
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
                            hintText: 'Search user by name or email...',
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
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: 'Refresh accounts directory',
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: usersAsync.isLoading || usersAsync.isRefreshing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: _primaryAccent,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            color: _primaryAccent,
                            size: 18,
                          ),
                    onPressed: () => ref.invalidate(adminUsersProvider),
                  ),
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
                decoration: kCardDecoration,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 40,
                      color: kMutedColor,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No User Accounts Found',
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
                : <AdminUser>[];

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
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: DataTable(
                                  headingRowHeight: 38,
                                  dataRowMinHeight: 48,
                                  dataRowMaxHeight: 48,
                                  headingRowColor: WidgetStateProperty.all(
                                    kDashBg,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('USER PROFILE', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10.5, color: kMutedColor, letterSpacing: 0.8))),
                                    DataColumn(label: Text('SUBSCRIPTION TIER', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10.5, color: kMutedColor, letterSpacing: 0.8))),
                                    DataColumn(label: Text('ACCOUNT STATUS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10.5, color: kMutedColor, letterSpacing: 0.8))),
                                    DataColumn(label: Text('JOINED DATE', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10.5, color: kMutedColor, letterSpacing: 0.8))),
                                    DataColumn(label: Text('GOVERNANCE ACTIONS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10.5, color: kMutedColor, letterSpacing: 0.8))),
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
                                                  Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kTitleColor)),
                                                  if (u.age != null) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                        color: kDashBg,
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(color: kDashBorder),
                                                      ),
                                                      child: Text('${u.age} yrs', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: kBodyColor)),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Text(u.email, style: const TextStyle(fontSize: 11, color: kLabelColor)),
                                            ],
                                          ),
                                        ),
                                        DataCell(_buildTierBadge(u.subscriptionTier)),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: (u.isBanned ? _danger : _success).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              u.isBanned ? 'Banned' : 'Active',
                                              style: TextStyle(
                                                color: u.isBanned ? _danger : _success,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(Text('${u.createdAt.day}/${u.createdAt.month}/${u.createdAt.year}', style: const TextStyle(color: kLabelColor, fontSize: 12))),
                                        DataCell(
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert_rounded, color: kLabelColor, size: 18),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            onSelected: (value) => _handleUserAction(context, u, value),
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'toggle_ban',
                                                child: Row(
                                                  children: [
                                                    Icon(u.isBanned ? Icons.check_circle_outline_rounded : Icons.block_rounded, color: u.isBanned ? _success : _danger, size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(u.isBanned ? 'Unban Account' : 'Ban Account', style: const TextStyle(fontSize: 12.5)),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'reset_password',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.lock_reset_rounded, color: _primaryAccent, size: 16),
                                                    SizedBox(width: 8),
                                                    Text('Send Password Reset', style: TextStyle(fontSize: 12.5)),
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
                            'Showing ${startIndex + 1} - $endIndex of ${filtered.length} users',
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
              Center(child: Text('Error loading users governance: $err')),
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

  Widget _buildTierBadge(String tier) {
    Color color;
    if (tier == 'VIP Subscriber') {
      color = kPurple;
    } else if (tier == 'Single-Card Buyer') {
      color = _primaryAccent;
    } else if (tier == 'Free Plan' || tier == 'Free Guest') {
      color = kSuccess;
    } else if (tier == 'Guest User') {
      color = kWarning;
    } else {
      color = kLabelColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tier,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
