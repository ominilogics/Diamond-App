import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';

// Premium Theme Colors
const _sidebarBg = Color(0xFF0F172A);
const _sidebarItemActiveBg = Color(0xFF1E293B);
const _sidebarText = Color(0xFF94A3B8);
const _sidebarTextActive = Colors.white;
const _bg = Color(0xFFF1F5F9);
const _cardBg = Colors.white;
const _primaryAccent = Color(0xFF3B82F6);
const _danger = Color(0xFFEF4444);
const _success = Color(0xFF10B981);

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          // Elegant Sidebar
          Container(
            width: 260,
            color: _sidebarBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 36,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.diamond_outlined,
                          color: _primaryAccent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Rivon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSidebarItem(0, Icons.category_rounded, 'Categories'),
                _buildSidebarItem(1, Icons.style_rounded, 'Cards'),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar Area
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    color: _cardBg,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedIndex == 0
                            ? 'Categories Management'
                            : 'Cards Management',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: _primaryAccent,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Admin',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Cached Views using IndexedStack
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: const [
                        _CategoriesAdminView(),
                        _CardsAdminView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? _sidebarItemActiveBg : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? _primaryAccent : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? _sidebarTextActive : _sidebarText,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? _sidebarTextActive : _sidebarText,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CATEGORIES VIEW
// -----------------------------------------------------------------------------
class _CategoriesAdminView extends ConsumerWidget {
  const _CategoriesAdminView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Search / Filter space (placeholder for professional look)
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon:
                      categoriesAsync.isLoading || categoriesAsync.isRefreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: _primaryAccent,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.refresh, color: _primaryAccent),
                  onPressed:
                      categoriesAsync.isLoading || categoriesAsync.isRefreshing
                      ? null
                      : () => ref.invalidate(adminCategoriesProvider),
                  tooltip: 'Refresh Data',
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCategoryDialog(context, ref),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Add Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
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
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: categoriesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: _primaryAccent),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error: \$err',
                  style: const TextStyle(color: _danger),
                ),
              ),
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 16),
                        Text(
                          'No categories found',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: const Color(0xFFF1F5F9),
                        dataTableTheme: const DataTableThemeData(
                          headingRowColor: WidgetStatePropertyAll(
                            Color(0xFFF8FAFC),
                          ),
                        ),
                      ),
                      child: DataTable(
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                        dataRowMinHeight: 60,
                        dataRowMaxHeight: 60,
                        columns: const [
                          DataColumn(label: Text('CATEGORY ID')),
                          DataColumn(label: Text('NAME')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: categories.map((cat) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  cat.id.substring(0, 8).toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  cat.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cat.isActive
                                        ? _success.withValues(alpha: 0.1)
                                        : _danger.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    cat.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: cat.isActive ? _success : _danger,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: _primaryAccent,
                                      ),
                                      tooltip: 'Edit Category',
                                      onPressed: () => _showCategoryDialog(
                                        context,
                                        ref,
                                        existingId: cat.id,
                                        initialName: cat.name,
                                        initialIsActive: cat.isActive,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: _danger,
                                      ),
                                      tooltip: 'Disable Category',
                                      onPressed: () =>
                                          _deleteCategory(context, ref, cat.id),
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
      ],
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    String? existingId,
    String? initialName,
    bool initialIsActive = true,
  }) {
    final controller = TextEditingController(text: initialName);
    bool isActive = initialIsActive;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: !isSaving,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                existingId == null ? 'Create New Category' : 'Edit Category',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    if (existingId != null) ...[
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: const Text(
                          'Active Status',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        value: isActive,
                        activeColor: _success,
                        onChanged: (val) => setState(() => isActive = val),
                      ),
                    ],
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (controller.text.trim().isNotEmpty) {
                            setState(() => isSaving = true);
                            try {
                              if (existingId == null) {
                                await ref
                                    .read(adminRepositoryProvider)
                                    .addCategory(controller.text.trim());
                              } else {
                                await ref
                                    .read(adminRepositoryProvider)
                                    .updateCategory(
                                      existingId,
                                      controller.text.trim(),
                                      isActive,
                                    );
                              }
                              ref.invalidate(adminCategoriesProvider);
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              setState(() => isSaving = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed: $e')),
                                );
                              }
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Details'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteCategory(BuildContext context, WidgetRef ref, String id) {
    bool isDeleting = false;
    showDialog(
      context: context,
      barrierDismissible: !isDeleting,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Confirm Disabling'),
            content: const Text(
              'Are you sure you want to disable this category? This acts as a soft-delete.',
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _danger,
                  foregroundColor: Colors.white,
                ),
                onPressed: isDeleting
                    ? null
                    : () async {
                        setState(() => isDeleting = true);
                        try {
                          await ref
                              .read(adminRepositoryProvider)
                              .deleteCategory(id);
                          ref.invalidate(adminCategoriesProvider);
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          setState(() => isDeleting = false);
                          if (context.mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                        }
                      },
                child: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Disable Category'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CARDS VIEW
// -----------------------------------------------------------------------------
class _CardsAdminView extends ConsumerWidget {
  const _CardsAdminView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(adminCardsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                  hintText: 'Search cards...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: cardsAsync.isLoading || cardsAsync.isRefreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: _primaryAccent,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.refresh, color: _primaryAccent),
                  onPressed: cardsAsync.isLoading || cardsAsync.isRefreshing
                      ? null
                      : () => ref.invalidate(adminCardsProvider),
                  tooltip: 'Refresh Data',
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCardDialog(context, ref),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Add Card',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
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
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: cardsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: _primaryAccent),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error: \$err',
                  style: const TextStyle(color: _danger),
                ),
              ),
              data: (cards) {
                if (cards.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.style_outlined,
                          size: 64,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No cards found',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: const Color(0xFFF1F5F9),
                        dataTableTheme: const DataTableThemeData(
                          headingRowColor: WidgetStatePropertyAll(
                            Color(0xFFF8FAFC),
                          ),
                        ),
                      ),
                      child: DataTable(
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                        dataRowMinHeight: 70,
                        dataRowMaxHeight: 70,
                        columns: const [
                          DataColumn(label: Text('CARD ID')),
                          DataColumn(label: Text('TITLE')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: cards.map((card) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  card.id.substring(0, 8).toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  card.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: card.isActive
                                        ? _success.withValues(alpha: 0.1)
                                        : _danger.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    card.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: card.isActive ? _success : _danger,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                        color: Colors.blueGrey,
                                      ),
                                      tooltip: 'Preview Card',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AdminCardPreviewScreen(
                                                  title: card.title,
                                                  frontMessage:
                                                      card.defaultFrontMessage,
                                                  insideMessage:
                                                      card.defaultInsideMessage,
                                                  imageProvider: NetworkImage(
                                                    card.coverImageUrl,
                                                  ),
                                                  heroTag:
                                                      'preview_\${card.id}',
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: _primaryAccent,
                                      ),
                                      tooltip: 'Edit Card',
                                      onPressed: () => _showCardDialog(
                                        context,
                                        ref,
                                        existingId: card.id,
                                        initialTitle: card.title,
                                        initialIsActive: card.isActive,
                                        initialFrontMessage:
                                            card.defaultFrontMessage,
                                        initialInsideMessage:
                                            card.defaultInsideMessage,
                                        existingImageUrl: card.coverImageUrl,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: _danger,
                                      ),
                                      tooltip: 'Disable Card',
                                      onPressed: () =>
                                          _deleteCard(context, ref, card.id),
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
      ],
    );
  }

  void _showCardDialog(
    BuildContext context,
    WidgetRef ref, {
    String? existingId,
    String? initialTitle,
    bool initialIsActive = true,
    String? initialFrontMessage,
    String? initialInsideMessage,
    String? existingImageUrl,
  }) {
    final titleCtrl = TextEditingController(text: initialTitle);
    final frontMsgCtrl = TextEditingController(text: initialFrontMessage);
    final insideMsgCtrl = TextEditingController(text: initialInsideMessage);
    bool isActive = initialIsActive;
    bool isSaving = false;

    final categoriesAsync = ref.watch(adminCategoriesProvider);
    String? selectedCategoryId;
    PlatformFile? selectedImage;

    showDialog(
      context: context,
      barrierDismissible: !isSaving,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                existingId == null ? 'Create New Card' : 'Edit Card Metadata',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (existingId == null) ...[
                        categoriesAsync.when(
                          data: (categories) {
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Category',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: selectedCategoryId,
                              items: categories
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => selectedCategoryId = val),
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) =>
                              const Text('Error loading categories'),
                        ),
                        const SizedBox(height: 20),
                      ],
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: 'Card Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      if (existingId == null) ...[
                        const SizedBox(height: 20),
                        TextField(
                          controller: frontMsgCtrl,
                          decoration: InputDecoration(
                            labelText: 'Default Front Message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: insideMsgCtrl,
                          decoration: InputDecoration(
                            labelText: 'Default Inside Message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await FilePicker.platform
                                      .pickFiles(
                                        type: FileType.image,
                                        withData: true,
                                      );
                                  if (result != null) {
                                    setState(
                                      () => selectedImage = result.files.first,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Browse Cover'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  selectedImage?.name ??
                                      'No image selected for upload',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (existingId != null) ...[
                        const SizedBox(height: 24),
                        SwitchListTile(
                          title: const Text(
                            'Active Status',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          value: isActive,
                          activeColor: _success,
                          onChanged: (val) => setState(() => isActive = val),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ImageProvider? provider;
                    if (selectedImage?.bytes != null) {
                      provider = MemoryImage(selectedImage!.bytes!);
                    } else if (existingImageUrl != null) {
                      provider = NetworkImage(existingImageUrl);
                    }

                    if (provider != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminCardPreviewScreen(
                            title: titleCtrl.text,
                            frontMessage: frontMsgCtrl.text,
                            insideMessage: insideMsgCtrl.text,
                            imageProvider: provider!,
                            heroTag: 'draft_preview',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select a cover image to preview.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Preview',
                    style: TextStyle(
                      color: _primaryAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          try {
                            if (existingId == null) {
                              if (titleCtrl.text.trim().isNotEmpty &&
                                  selectedCategoryId != null &&
                                  selectedImage?.bytes != null) {
                                setState(() => isSaving = true);
                                await ref
                                    .read(adminRepositoryProvider)
                                    .addCard(
                                      categoryId: selectedCategoryId!,
                                      title: titleCtrl.text.trim(),
                                      defaultFrontMessage: frontMsgCtrl.text
                                          .trim(),
                                      defaultInsideMessage: insideMsgCtrl.text
                                          .trim(),
                                      imageBytes: selectedImage!.bytes!,
                                      fileExtension:
                                          selectedImage!.extension ?? 'jpg',
                                    );
                                ref.invalidate(adminCardsProvider);
                                if (context.mounted) Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please fill all required fields (Category, Title, and Cover Image).',
                                    ),
                                  ),
                                );
                              }
                            } else {
                              if (titleCtrl.text.trim().isNotEmpty) {
                                setState(() => isSaving = true);
                                await ref
                                    .read(adminRepositoryProvider)
                                    .updateCard(
                                      cardId: existingId,
                                      title: titleCtrl.text.trim(),
                                      isActive: isActive,
                                    );
                                ref.invalidate(adminCardsProvider);
                                if (context.mounted) Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Card title cannot be empty.',
                                    ),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            setState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to save data: $e'),
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Details'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteCard(BuildContext context, WidgetRef ref, String id) {
    bool isDeleting = false;
    showDialog(
      context: context,
      barrierDismissible: !isDeleting,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Confirm Disabling'),
            content: const Text(
              'Are you sure you want to disable this card? This acts as a soft-delete.',
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _danger,
                  foregroundColor: Colors.white,
                ),
                onPressed: isDeleting
                    ? null
                    : () async {
                        setState(() => isDeleting = true);
                        try {
                          await ref
                              .read(adminRepositoryProvider)
                              .deleteCard(id);
                          ref.invalidate(adminCardsProvider);
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          setState(() => isDeleting = false);
                          if (context.mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                        }
                      },
                child: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Disable Card'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AdminCardPreviewScreen extends StatelessWidget {
  final String title;
  final String frontMessage;
  final String insideMessage;
  final ImageProvider imageProvider;
  final String heroTag;

  const AdminCardPreviewScreen({
    super.key,
    required this.title,
    required this.frontMessage,
    required this.insideMessage,
    required this.imageProvider,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          'Preview: $title',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Row(
        children: [
          // Image Viewer (Left Side)
          Expanded(
            flex: 2,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: heroTag,
                child: Image(
                  image: imageProvider,
                  fit: BoxFit
                      .contain, // Ensures the entire image is visible with absolutely no clipping
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Metadata Panel (Right Side)
          Container(
            width: 350,
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Card Data',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDataField(
                  'Card Title',
                  title.isEmpty ? 'Untitled' : title,
                ),
                const SizedBox(height: 24),
                _buildDataField(
                  'Front Message',
                  frontMessage.isEmpty
                      ? '(No default front message)'
                      : frontMessage,
                ),
                const SizedBox(height: 24),
                _buildDataField(
                  'Inside Message',
                  insideMessage.isEmpty
                      ? '(No default inside message)'
                      : insideMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
