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
                width: 480,
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
                        horizontal: 20,
                        vertical: 16,
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _primaryAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.category_rounded,
                              color: _primaryAccent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Add New Category',
                            style: TextStyle(
                              fontSize: 17,
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
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kTitleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: titleController,
                            autofocus: true,
                            style: const TextStyle(
                              fontSize: 14,
                              color: kTitleColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g., Mother\'s Day, Birthdays',
                              hintStyle: const TextStyle(
                                color: kMutedColor,
                                fontSize: 13.5,
                              ),
                              filled: true,
                              fillColor: kDashBg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
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
                        horizontal: 20,
                        vertical: 14,
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
                                horizontal: 18,
                                vertical: 11,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                                horizontal: 20,
                                vertical: 11,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
                                : const Text(
                                    'Create Category',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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

  void _showManageCategoryDialog(
    BuildContext context,
    AdminCategory category,
  ) {
    final titleController = TextEditingController(text: category.name);
    bool isActive = category.isActive;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 480,
                decoration: BoxDecoration(
                  color: kDashCardBg,
                  borderRadius: BorderRadius.circular(kCardRadius),
                  border: Border.all(color: kDashBorder),
                  boxShadow: [kCardShadow],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _primaryAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: _primaryAccent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Manage Category',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
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
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Name & Edit Button
                          const Text(
                            'Category Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kTitleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: titleController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: kTitleColor,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: kDashBg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: kDashBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: kDashBorder,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Review / Status Switch & Deactivate Option
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: kDashBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kDashBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isActive
                                          ? 'Active'
                                          : 'Inactive',
                                      style: TextStyle(
                                        color: isActive
                                            ? _success
                                            : kLabelColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Switch(
                                      value: isActive,
                                      activeThumbColor: _primaryAccent,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (val) {
                                        setDialogState(
                                          () => isActive = val,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isActive
                                      ? 'Visible to users on card catalog and template selectors.'
                                      : 'Hidden from card catalog and deactivated for users.',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: kLabelColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // View Cards in this Category
                          if (widget.onSelectCategoryFilter != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: kDashBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kDashBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _primaryAccent.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.style_outlined,
                                      color: _primaryAccent,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Category Cards',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: kTitleColor,
                                          ),
                                        ),
                                        Text(
                                          'View cards in this category',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: kLabelColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      widget.onSelectCategoryFilter?.call(
                                        category.id,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'View Cards',
                                      style: TextStyle(
                                        fontSize: 13,
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
                    ),

                    // Dialog Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
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
                                horizontal: 18,
                                vertical: 11,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final name =
                                        titleController.text.trim();
                                    if (name.isEmpty) return;

                                    setDialogState(() => isSaving = true);
                                    try {
                                      final repo = ref.read(
                                        adminRepositoryProvider,
                                      );
                                      await repo.updateCategory(
                                        category.id,
                                        name,
                                        isActive,
                                      );
                                      ref.invalidate(
                                        adminCategoriesProvider,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        setDialogState(
                                          () => isSaving = false,
                                        );
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
                                horizontal: 20,
                                vertical: 11,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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
                  Icons.delete_outline_rounded,
                  color: _danger,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Delete Category',
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
                'Are you sure you want to delete "${category.name}"?',
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
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: kCardDecoration,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;

              final searchField = SizedBox(
                height: 42,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {});
                    _onSearchChanged(val);
                  },
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontSize: 13.5, color: kTitleColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kDashBg,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kDashBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kDashBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: _primaryAccent,
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: kMutedColor,
                      size: 18,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 42,
                      minHeight: 42,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 42,
                              minHeight: 42,
                            ),
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 16,
                              color: kMutedColor,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    hintText: 'Search categories...',
                    hintStyle: const TextStyle(
                      color: kMutedColor,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              );

              final actionButtons = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: 'Refresh catalog list',
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      icon: categoriesAsync.isLoading ||
                              categoriesAsync.isRefreshing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: _primaryAccent,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              color: _primaryAccent,
                              size: 20,
                            ),
                      onPressed: () => ref.invalidate(adminCategoriesProvider),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(
                      'Add Category',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchField,
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actionButtons,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: searchField,
                  ),
                  const SizedBox(width: 12),
                  actionButtons,
                ],
              );
            },
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
                                    headingRowHeight: 46,
                                    dataRowMinHeight: 58,
                                    dataRowMaxHeight: 58,
                                    headingRowColor: WidgetStateProperty.all(
                                      kDashBg,
                                    ),
                                    showCheckboxColumn: false,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'CATEGORY NAME',
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
                                          'STATUS',
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
                                    rows: paginatedList.map((c) {
                                      return DataRow(
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
                                                const SizedBox(width: 12),
                                                Flexible(
                                                  child: Text(
                                                    c.name,
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
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
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
                                              child: Text(
                                                c.isActive
                                                    ? 'Active'
                                                    : 'Inactive',
                                                style: TextStyle(
                                                  color: c.isActive
                                                      ? _success
                                                      : kLabelColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      _showManageCategoryDialog(
                                                        context,
                                                        c,
                                                      ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: _primaryAccent,
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                          vertical: 6,
                                                    ),
                                                    minimumSize: const Size(0, 34),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Manage',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                OutlinedButton(
                                                  onPressed: () =>
                                                      _confirmDeleteCategory(
                                                        context,
                                                        c,
                                                      ),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: _danger,
                                                    side: BorderSide(
                                                      color: _danger
                                                          .withValues(alpha: 0.35),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                          vertical: 6,
                                                    ),
                                                    minimumSize: const Size(0, 34),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                              'Showing ${startIndex + 1} - $endIndex of ${filtered.length} categories',
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
                Center(child: Text('Error loading categories: $err')),
          ),
        ),
      ],
    );
  }
}
