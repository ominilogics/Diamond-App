import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';

const _primaryAccent = Color(0xFF3B82F6);
const _danger = Color(0xFFEF4444);
const _success = Color(0xFF10B981);
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
                width: 440,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
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
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
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
                              Icons.category_rounded,
                              color: _primaryAccent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Add New Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(context),
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
                          const Text(
                            'Category Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: titleController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'e.g., Mother\'s Day, Birthdays',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
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
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0)),
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
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
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
                                      if (context.mounted)
                                        Navigator.pop(context);
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
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
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
                width: 440,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
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
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
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
                              Icons.edit_note_rounded,
                              color: _primaryAccent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Edit Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(context),
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
                          const Text(
                            'Category Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: SwitchListTile(
                              title: const Text(
                                'Category Active Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                isActive
                                    ? 'Visible to users on card catalog'
                                    : 'Hidden from card catalog',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              value: isActive,
                              activeColor: _success,
                              onChanged: (val) =>
                                  setState(() => isActive = val),
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
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0)),
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
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
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
                                      if (context.mounted)
                                        Navigator.pop(context);
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
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _danger,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Deactivate Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to deactivate "${category.name}"?',
                style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
              ),
              if (activeCardsCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Warning: This category contains $activeCardsCount active card template(s).',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB45309),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _danger,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Deactivate Selected',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to deactivate ${_selectedCategoryIds.length} selected categories?',
            style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
              // Debounced Search Field
              Container(
                width: 280,
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
                    hintText: 'Search category catalog...',
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
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (_selectedCategoryIds.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_selectedCategoryIds.length} item(s) selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _primaryAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmBatchDeleteCategories(context),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: _danger,
                        size: 18,
                      ),
                      label: const Text(
                        'Deactivate Selected',
                        style: TextStyle(
                          color: _danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                  Tooltip(
                    message: 'Refresh catalog list',
                    child: IconButton(
                      icon:
                          categoriesAsync.isLoading ||
                              categoriesAsync.isRefreshing
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
                      onPressed: () => ref.invalidate(adminCategoriesProvider),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'Add Category',
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
            ],
          ),
        ),
        const SizedBox(height: 24),

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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 56,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Categories Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _activeSearchQuery.isNotEmpty
                            ? 'No category matches "$_activeSearchQuery".'
                            : 'Click "Add Category" to get started.',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
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
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xFF475569),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                DataColumn(
                                  label: Text(
                                    'STATUS',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.5,
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
                                      letterSpacing: 0.5,
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
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _primaryAccent.withValues(
                                                alpha: 0.08,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.folder_open_rounded,
                                              size: 18,
                                              color: _primaryAccent,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Flexible(
                                            child: Text(
                                              c.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (c.isActive
                                                      ? _success
                                                      : const Color(0xFF64748B))
                                                  .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: c.isActive
                                                    ? _success
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              c.isActive
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style: TextStyle(
                                                color: c.isActive
                                                    ? _success
                                                    : const Color(0xFF64748B),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
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
                                                icon: const Icon(
                                                  Icons.style_outlined,
                                                  color: _primaryAccent,
                                                  size: 20,
                                                ),
                                                onPressed: () => widget
                                                    .onSelectCategoryFilter
                                                    ?.call(c.id),
                                              ),
                                            ),
                                          Tooltip(
                                            message: 'Edit category',
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Color(0xFF64748B),
                                                size: 20,
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
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: _danger,
                                                size: 20,
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
                              'Showing ${startIndex + 1} - $endIndex of ${filtered.length} categories',
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
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Previous'),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Page ${_currentPage + 1} of $totalPages',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: _currentPage < totalPages - 1
                                      ? () => setState(() => _currentPage++)
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
                Center(child: Text('Error loading categories: $err')),
          ),
        ),
      ],
    );
  }
}
