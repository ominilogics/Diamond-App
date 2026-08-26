import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';

const _primaryAccent = Color(0xFF3B82F6);
const _danger = Color(0xFFEF4444);
const _success = Color(0xFF10B981);
const int _itemsPerPage = 15;

class CardsAdminView extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  const CardsAdminView({super.key, this.initialCategoryId});

  @override
  ConsumerState<CardsAdminView> createState() => _CardsAdminViewState();
}

class _CardsAdminViewState extends ConsumerState<CardsAdminView> {
  final _searchController = TextEditingController();
  String? _selectedCategoryFilter;
  final Set<String> _selectedCardIds = {};
  Timer? _debounceTimer;
  String _activeSearchQuery = '';
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _selectedCategoryFilter = widget.initialCategoryId;
  }

  @override
  void didUpdateWidget(CardsAdminView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategoryId != oldWidget.initialCategoryId) {
      setState(() {
        _selectedCategoryFilter = widget.initialCategoryId;
        _currentPage = 0;
      });
    }
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

  void _showAddCardDialog(BuildContext context) {
    final titleController = TextEditingController();
    final frontMsgController = TextEditingController();
    final insideMsgController = TextEditingController();

    String? selectedCategoryId;
    PlatformFile? selectedFile;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final categoriesAsync = ref.watch(adminCategoriesProvider);
            final categories = categoriesAsync.valueOrNull ?? [];

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 500,
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
                              Icons.style_rounded,
                              color: _primaryAccent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Add New Card Template',
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
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Card Category',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: selectedCategoryId,
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
                                hint: const Text('Select a category'),
                                items: categories.map((c) {
                                  return DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => selectedCategoryId = val),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Card Title',
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
                                  hintText: 'e.g., Happy Mother\'s Day Classic',
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
                              const Text(
                                'Front Cover Preset Text',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: frontMsgController,
                                decoration: InputDecoration(
                                  hintText: 'Front cover text preset...',
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
                              const Text(
                                'Inside Page Preset Text',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: insideMsgController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText:
                                      'Inside page default greeting text...',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.all(16),
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
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final result = await FilePicker.platform
                                            .pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: [
                                                'jpg',
                                                'jpeg',
                                                'png',
                                                'webp',
                                              ],
                                              withData: true,
                                            );
                                        if (result != null &&
                                            result.files.isNotEmpty) {
                                          setState(
                                            () => selectedFile =
                                                result.files.first,
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.image_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        selectedFile == null
                                            ? 'Upload Cover Artwork'
                                            : 'Change Artwork',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(
                                          0xFF0F172A,
                                        ),
                                        elevation: 0,
                                        side: const BorderSide(
                                          color: Color(0xFFCBD5E1),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    if (selectedFile != null)
                                      Expanded(
                                        child: Text(
                                          selectedFile!.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: _success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    final title = titleController.text.trim();
                                    final catId = selectedCategoryId;
                                    final file = selectedFile;

                                    if (title.isEmpty ||
                                        catId == null ||
                                        file == null ||
                                        file.bytes == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please complete all fields and select artwork',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => isSaving = true);
                                    try {
                                      final repo = ref.read(
                                        adminRepositoryProvider,
                                      );
                                      final ext = file.extension ?? 'jpg';
                                      await repo.addCard(
                                        categoryId: catId,
                                        title: title,
                                        defaultFrontMessage: frontMsgController
                                            .text
                                            .trim(),
                                        defaultInsideMessage:
                                            insideMsgController.text.trim(),
                                        imageBytes: file.bytes!,
                                        fileExtension: ext,
                                      );
                                      ref.invalidate(adminCardsProvider);
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
                                              'Error adding card: $e',
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
                                : const Text('Create Card Template'),
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

  void _showEditCardDialog(BuildContext context, AdminCard card) {
    final titleController = TextEditingController(text: card.title);
    bool isActive = card.isActive;
    PlatformFile? replacementFile;
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
                width: 460,
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
                            'Edit Card Template',
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
                            'Card Title',
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
                          const Text(
                            'Replace Cover Artwork Image',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await FilePicker.platform
                                        .pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: [
                                            'jpg',
                                            'jpeg',
                                            'png',
                                            'webp',
                                          ],
                                          withData: true,
                                        );
                                    if (result != null &&
                                        result.files.isNotEmpty) {
                                      setState(
                                        () => replacementFile =
                                            result.files.first,
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.image_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    replacementFile == null
                                        ? 'Select New Image'
                                        : 'Change New Image',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF0F172A),
                                    elevation: 0,
                                    side: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (replacementFile != null)
                                  Expanded(
                                    child: Text(
                                      replacementFile!.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: _success,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                else
                                  const Text(
                                    'Keep current artwork',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
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
                                'Card Active Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                isActive
                                    ? 'Visible to users'
                                    : 'Hidden from catalog',
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
                                    final title = titleController.text.trim();
                                    if (title.isEmpty) return;

                                    setState(() => isSaving = true);
                                    try {
                                      final repo = ref.read(
                                        adminRepositoryProvider,
                                      );
                                      await repo.updateCard(
                                        cardId: card.id,
                                        title: title,
                                        isActive: isActive,
                                        imageBytes: replacementFile?.bytes,
                                        fileExtension:
                                            replacementFile?.extension,
                                      );
                                      ref.invalidate(adminCardsProvider);
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
                                              'Error updating card: $e',
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

  void _showCardPreviewDialog(
    BuildContext context,
    AdminCard card,
    String categoryName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 520,
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
                          Icons.remove_red_eye_rounded,
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
                              card.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Category: $categoryName',
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              height: 260,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  card.coverImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, _, __) => Container(
                                    width: 220,
                                    color: const Color(0xFFF1F5F9),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image_rounded,
                                          size: 48,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Image loading error',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (card.defaultFrontMessage.isNotEmpty) ...[
                            const Text(
                              'Front Cover Preset Text',
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
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                card.defaultFrontMessage,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (card.defaultInsideMessage.isNotEmpty) ...[
                            const Text(
                              'Inside Page Preset Greeting',
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
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                card.defaultInsideMessage,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (card.isActive
                                      ? _success
                                      : const Color(0xFF64748B))
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          card.isActive
                              ? 'Active in Catalog'
                              : 'Inactive / Hidden',
                          style: TextStyle(
                            color: card.isActive
                                ? _success
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditCardDialog(context, card);
                            },
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Edit Card'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                            child: const Text('Close Preview'),
                          ),
                        ],
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

  void _confirmDeleteCard(BuildContext context, AdminCard card) {
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
                'Deactivate Card Template',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to deactivate "${card.title}"?',
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
                await repo.deleteCard(card.id);
                ref.invalidate(adminCardsProvider);
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

  void _confirmBatchDeleteCards(BuildContext context) {
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
                'Deactivate Selected Cards',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to deactivate ${_selectedCardIds.length} selected card templates?',
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
                await repo.deleteCardsBatch(_selectedCardIds.toList());
                _selectedCardIds.clear();
                ref.invalidate(adminCardsProvider);
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
    final cardsAsync = ref.watch(adminCardsProvider);
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Action Header Bar Surface
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
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Debounced Search Field
                  Container(
                    width: 260,
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
                        hintText: 'Search card title...',
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
                  // Category Filter Dropdown
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
                      child: DropdownButton<String?>(
                        value: _selectedCategoryFilter,
                        hint: const Text(
                          'All Categories',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...categories.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedCategoryFilter = val;
                            _currentPage = 0;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (_selectedCardIds.isNotEmpty) ...[
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
                        '${_selectedCardIds.length} item(s) selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _primaryAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmBatchDeleteCards(context),
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
                    message: 'Refresh card list',
                    child: IconButton(
                      icon: cardsAsync.isLoading || cardsAsync.isRefreshing
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
                      onPressed: () => ref.invalidate(adminCardsProvider),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCardDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'Add Card Template',
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

        // Cards Table Surface
        Expanded(
          child: cardsAsync.when(
            data: (cards) {
              final filtered = cards.where((c) {
                final matchesQuery = c.title.toLowerCase().contains(
                  _activeSearchQuery,
                );
                final matchesCategory =
                    _selectedCategoryFilter == null ||
                    c.categoryId == _selectedCategoryFilter;
                return matchesQuery && matchesCategory;
              }).toList();

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
                        Icons.style_outlined,
                        size: 56,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Card Templates Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _activeSearchQuery.isNotEmpty ||
                                _selectedCategoryFilter != null
                            ? 'No cards match your active filter settings.'
                            : 'Click "Add Card Template" to upload card artwork.',
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
                  : <AdminCard>[];

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
                                    dataRowMinHeight: 68,
                                    dataRowMaxHeight: 68,
                                    headingRowColor: WidgetStateProperty.all(
                                      const Color(0xFFF8FAFC),
                                    ),
                                    showCheckboxColumn: true,
                                    onSelectAll: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedCardIds.addAll(
                                            filtered.map((c) => c.id),
                                          );
                                        } else {
                                          _selectedCardIds.clear();
                                        }
                                      });
                                    },
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'CARD TITLE',
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
                                    'FEATURED',
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
                              rows: paginatedList.map((card) {
                                final isSelected = _selectedCardIds.contains(
                                  card.id,
                                );
                                return DataRow(
                                  selected: isSelected,
                                  onSelectChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedCardIds.add(card.id);
                                      } else {
                                        _selectedCardIds.remove(card.id);
                                      }
                                    });
                                  },
                                  cells: [
                                    DataCell(
                                      InkWell(
                                        onTap: () {
                                          final cat = categories.firstWhere(
                                            (c) => c.id == card.categoryId,
                                            orElse: () => AdminCategory(
                                              id: '',
                                              name: 'General',
                                              isActive: true,
                                            ),
                                          );
                                          _showCardPreviewDialog(
                                            context,
                                            card,
                                            cat.name,
                                          );
                                        },
                                        child: Text(
                                          card.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Switch(
                                        value: card.isFeatured,
                                        activeColor: _primaryAccent,
                                        onChanged: (val) async {
                                          await ref
                                              .read(adminRepositoryProvider)
                                              .toggleFeaturedCard(card.id, val);
                                          ref.invalidate(adminCardsProvider);
                                        },
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
                                              (card.isActive
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
                                                color: card.isActive
                                                    ? _success
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              card.isActive
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style: TextStyle(
                                                color: card.isActive
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
                                          Tooltip(
                                            message: 'Preview Card',
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.remove_red_eye_outlined,
                                                color: _primaryAccent,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                final cat = categories
                                                    .firstWhere(
                                                      (c) =>
                                                          c.id ==
                                                          card.categoryId,
                                                      orElse: () =>
                                                          AdminCategory(
                                                            id: '',
                                                            name: 'General',
                                                            isActive: true,
                                                          ),
                                                    );
                                                _showCardPreviewDialog(
                                                  context,
                                                  card,
                                                  cat.name,
                                                );
                                              },
                                            ),
                                          ),
                                          Tooltip(
                                            message: 'Edit card details',
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Color(0xFF64748B),
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _showEditCardDialog(
                                                    context,
                                                    card,
                                                  ),
                                            ),
                                          ),
                                          Tooltip(
                                            message: 'Deactivate card',
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: _danger,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _confirmDeleteCard(
                                                    context,
                                                    card,
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
                              'Showing ${startIndex + 1} - $endIndex of ${filtered.length} cards',
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
                Center(child: Text('Error loading cards: $err')),
          ),
        ),
      ],
    );
  }
}
