import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../admin_theme.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';

const _primaryAccent = kPrimary;
const _danger = kDanger;
const _success = kSuccess;
const int _itemsPerPage = 15;

class CategoriesAdminView extends ConsumerStatefulWidget {
  final ValueChanged<String>? onSelectCategoryFilter;

  const CategoriesAdminView({super.key, this.onSelectCategoryFilter});

  @override
  ConsumerState<CategoriesAdminView> createState() =>
      _CategoriesAdminViewState();
}

class _CategoriesAdminViewState extends ConsumerState<CategoriesAdminView> {
  final _searchController = TextEditingController();
  final Set<String> _selectedCategoryIds = {};
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

  void _showAddCategoryDialog(BuildContext context) {
    final titleController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 420,
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
                              Icons.category_rounded,
                              color: _primaryAccent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Add New Category',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kTitleColor,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(context),
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
                          const Text(
                            'Category Name',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kTitleColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: titleController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'e.g., Mother\'s Day, Birthdays',
                              hintStyle: const TextStyle(
                                color: kMutedColor,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: kDashBg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: kDashBorder,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final name = titleController.text.trim();
                                    if (name.isEmpty) return;

                                    setState(() => isSaving = true);
                                    try {
                                      final repo = ref.read(
                                        adminRepositoryProvider,
                                      );
                                      await repo.addCategory(name);
                                      ref.invalidate(adminCategoriesProvider);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        setState(() => isSaving = false);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error adding category: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
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
                            child: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Create Category'),
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
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, AdminCategory category) {
    final titleController = TextEditingController(text: category.name);
    bool isActive = category.isActive;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 420,
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
                              Icons.edit_note_rounded,
                              color: _primaryAccent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Edit Category',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kTitleColor,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(context),
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
                          const Text(
                            'Category Name',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kTitleColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: kDashBg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: kDashBorder,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kDashBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: kDashBorder,
                              ),
                            ),
                            child: SwitchListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Category Active Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: kTitleColor,
                                ),
                              ),
                              subtitle: Text(
                                isActive
                                    ? 'Visible to users on card catalog'
                                    : 'Hidden from card catalog',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: kLabelColor,
                                ),
                              ),
                              value: isActive,
                              activeThumbColor: _primaryAccent,
                              onChanged: (val) =>
                                  setState(() => isActive = val),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final name = titleController.text.trim();
                                    if (name.isEmpty) return;

                                    setState(() => isSaving = true);
                                    try {
                                      final repo = ref.read(
                                        adminRepositoryProvider,
                                      );
                                      await repo.updateCategory(
                                        category.id,
                                        name,
                                        isActive,
                                      );
                                      ref.invalidate(adminCategoriesProvider);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        setState(() => isSaving = false);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error updating category: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
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
                            child: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Save Changes'),
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
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, AdminCategory category) {
    final cardsAsync = ref.read(adminCardsProvider);
    final cards = cardsAsync.valueOrNull ?? [];
    final activeCardsCount = cards
        .where((c) => c.categoryId == category.id && c.isActive)
        .length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kDashCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _danger,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Deactivate Category',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: kTitleColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to deactivate "${category.name}"?',
                style: const TextStyle(fontSize: 13.5, color: kBodyColor),
              ),
              if (activeCardsCount > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kWarning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kWarning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: kWarning,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Warning: This category contains $activeCardsCount active card template(s).',
                          style: const TextStyle(
                            fontSize: 12,
                            color: kWarning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final repo = ref.read(adminRepositoryProvider);
                await repo.deleteCategory(category.id);
                ref.invalidate(adminCategoriesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }

  void _confirmBatchDeleteCategories(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kDashCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _danger,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Deactivate Selected',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: kTitleColor,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to deactivate ${_selectedCategoryIds.length} selected categories?',
            style: const TextStyle(fontSize: 13.5, color: kBodyColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final repo = ref.read(adminRepositoryProvider);
                await repo.deleteCategoriesBatch(_selectedCategoryIds.toList());
                _selectedCategoryIds.clear();
                ref.invalidate(adminCategoriesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Deactivate All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Action Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: kCardDecoration,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              // Debounced Search Field
              Container(
                width: 240,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: kDashBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kDashBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(fontSize: 12.5, color: kTitleColor),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                    icon: const Icon(
                      Icons.search_rounded,
                      color: kMutedColor,
                      size: 16,
                    ),
                    hintText: 'Search categories...',
                    hintStyle: const TextStyle(
                      color: kMutedColor,
                      fontSize: 12.5,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(width: 20, height: 20),
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 14,
                              color: kMutedColor,
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
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (_selectedCategoryIds.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_selectedCategoryIds.length} selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _primaryAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmBatchDeleteCategories(context),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: _danger,
                        size: 16,
                      ),
                      label: const Text(
                        'Deactivate Selected',
                        style: TextStyle(
                          color: _danger,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _danger.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                  Tooltip(
                    message: 'Refresh catalog list',
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
                      icon:
                          categoriesAsync.isLoading ||
                              categoriesAsync.isRefreshing
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
                      onPressed: () => ref.invalidate(adminCategoriesProvider),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text(
                      'Add Category',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
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
        ),
        const SizedBox(height: 14),

        // Categories Table Card Surface
        Expanded(
          child: categoriesAsync.when(
            data: (categories) {
              final filtered = categories
                  .where(
                    (c) => c.name.toLowerCase().contains(_activeSearchQuery),
                  )
                  .toList();

              if (filtered.isEmpty) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kDashCardBg,
                    borderRadius: BorderRadius.circular(kCardRadius),
                    border: Border.all(color: kDashBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 44,
                        color: kMutedColor,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No Categories Found',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kTitleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _activeSearchQuery.isNotEmpty
                            ? 'No category matches "$_activeSearchQuery".'
                            : 'Click "Add Category" to get started.',
                        style: const TextStyle(
                          color: kLabelColor,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Safe Pagination Slicing & State Synchronization
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
                  : <AdminCategory>[];

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
                                    dataRowMinHeight: 46,
                                    dataRowMaxHeight: 46,
                                    headingRowColor: WidgetStateProperty.all(
                                      kDashBg,
                                    ),
                                    showCheckboxColumn: true,
                                    onSelectAll: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedCategoryIds.addAll(
                                            filtered.map((c) => c.id),
                                          );
                                        } else {
                                          _selectedCategoryIds.clear();
                                        }
                                      });
                                    },
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'CATEGORY NAME',
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
                                          'STATUS',
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
                                    rows: paginatedList.map((c) {
                                      final isSelected = _selectedCategoryIds
                                          .contains(c.id);
                                      return DataRow(
                                        selected: isSelected,
                                        onSelectChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              _selectedCategoryIds.add(c.id);
                                            } else {
                                              _selectedCategoryIds.remove(c.id);
                                            }
                                          });
                                        },
                                        cells: [
                                          DataCell(
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: _primaryAccent.withValues(
                                                      alpha: 0.08,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  child: const Icon(
                                                    Icons.folder_open_rounded,
                                                    size: 15,
                                                    color: _primaryAccent,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Flexible(
                                                  child: Text(
                                                    c.name,
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
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    (c.isActive
                                                            ? _success
                                                            : kLabelColor)
                                                        .withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 5,
                                                    height: 5,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: c.isActive
                                                          ? _success
                                                          : kLabelColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    c.isActive
                                                        ? 'Active'
                                                        : 'Inactive',
                                                    style: TextStyle(
                                                      color: c.isActive
                                                          ? _success
                                                          : kLabelColor,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                if (widget.onSelectCategoryFilter !=
                                                    null)
                                                  Tooltip(
                                                    message:
                                                        'View cards in this category',
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                                                      icon: const Icon(
                                                        Icons.style_outlined,
                                                        color: _primaryAccent,
                                                        size: 16,
                                                      ),
                                                      onPressed: () => widget
                                                          .onSelectCategoryFilter
                                                          ?.call(c.id),
                                                    ),
                                                  ),
                                                Tooltip(
                                                  message: 'Edit category',
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                      color: kLabelColor,
                                                      size: 16,
                                                    ),
                                                    onPressed: () =>
                                                        _showEditCategoryDialog(
                                                          context,
                                                          c,
                                                        ),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Deactivate category',
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                                                    icon: const Icon(
                                                      Icons.delete_outline_rounded,
                                                      color: _danger,
                                                      size: 16,
                                                    ),
                                                    onPressed: () =>
                                                        _confirmDeleteCategory(
                                                          context,
                                                          c,
                                                        ),
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

                    // Pagination Control Footer
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
                              'Showing ${startIndex + 1} - $endIndex of ${filtered.length} categories',
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text('Previous', style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Page ${_currentPage + 1} of $totalPages',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: kTitleColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: _currentPage < totalPages - 1
                                      ? () => setState(() => _currentPage++)
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text('Next', style: TextStyle(fontSize: 12)),
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
                Center(child: Text('Error loading categories: $err')),
          ),
        ),
      ],
    );
  }
}
