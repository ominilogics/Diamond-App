import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../admin_theme.dart';
import '../providers/admin_provider.dart';
import '../../data/repositories/admin_repository.dart';

const _primaryAccent = kPrimary;
const _danger = kDanger;
const _success = kSuccess;
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
                              Icons.style_rounded,
                              color: _primaryAccent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Add Card Template',
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
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Card Category',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: kTitleColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCategoryId,
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
                                hint: const Text('Select a category', style: TextStyle(fontSize: 13)),
                                items: categories.map((c) {
                                  return DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => selectedCategoryId = val),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Card Title',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: kTitleColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: titleController,
                                style: const TextStyle(fontSize: 13, color: kTitleColor),
                                decoration: InputDecoration(
                                  hintText: 'e.g., Happy Mother\'s Day Classic',
                                  hintStyle: const TextStyle(fontSize: 13, color: kMutedColor),
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
                              const Text(
                                'Front Cover Preset Text',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: kTitleColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: frontMsgController,
                                style: const TextStyle(fontSize: 13, color: kTitleColor),
                                decoration: InputDecoration(
                                  hintText: 'Front cover text preset...',
                                  hintStyle: const TextStyle(fontSize: 13, color: kMutedColor),
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
                              const Text(
                                'Inside Page Preset Text',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: kTitleColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: insideMsgController,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 13, color: kTitleColor),
                                decoration: InputDecoration(
                                  hintText:
                                      'Inside page default greeting text...',
                                  hintStyle: const TextStyle(fontSize: 13, color: kMutedColor),
                                  filled: true,
                                  fillColor: kDashBg,
                                  contentPadding: const EdgeInsets.all(12),
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
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: kDashBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: kDashBorder,
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
                                        size: 16,
                                      ),
                                      label: Text(
                                        selectedFile == null
                                            ? 'Upload Artwork'
                                            : 'Change Artwork',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kDashCardBg,
                                        foregroundColor: kTitleColor,
                                        elevation: 0,
                                        side: const BorderSide(
                                          color: kDashBorder,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (selectedFile != null)
                                      Expanded(
                                        child: Text(
                                          selectedFile!.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: _success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
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
                              Icons.edit_note_rounded,
                              color: _primaryAccent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Edit Card Template',
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
                            'Card Title',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: kTitleColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: titleController,
                            style: const TextStyle(fontSize: 13, color: kTitleColor),
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
                          const Text(
                            'Replace Cover Artwork Image',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: kTitleColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: kDashBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: kDashBorder,
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
                                    size: 16,
                                  ),
                                  label: Text(
                                    replacementFile == null
                                        ? 'Select New Image'
                                        : 'Change New Image',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kDashCardBg,
                                    foregroundColor: kTitleColor,
                                    elevation: 0,
                                    side: const BorderSide(
                                      color: kDashBorder,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
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
                                      color: kMutedColor,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
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
                                'Card Active Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: kTitleColor,
                                ),
                              ),
                              subtitle: Text(
                                isActive
                                    ? 'Visible to users'
                                    : 'Hidden from catalog',
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
                          Icons.remove_red_eye_rounded,
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
                              card.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: kTitleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Category: $categoryName',
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: kDashBorder,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.network(
                                  card.coverImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 180,
                                    color: kDashBg,
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image_rounded,
                                          size: 36,
                                          color: kMutedColor,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Image error',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: kLabelColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (card.defaultFrontMessage.isNotEmpty) ...[
                            const Text(
                              'Front Cover Preset Text',
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
                                border: Border.all(
                                  color: kDashBorder,
                                ),
                              ),
                              child: Text(
                                card.defaultFrontMessage,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: kTitleColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (card.defaultInsideMessage.isNotEmpty) ...[
                            const Text(
                              'Inside Page Preset Greeting',
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
                                border: Border.all(
                                  color: kDashBorder,
                                ),
                              ),
                              child: Text(
                                card.defaultInsideMessage,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: kTitleColor,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (card.isActive
                                      ? _success
                                      : kLabelColor)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          card.isActive
                              ? 'Active in Catalog'
                              : 'Inactive / Hidden',
                          style: TextStyle(
                            color: card.isActive
                                ? _success
                                : kLabelColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
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
                            icon: const Icon(Icons.edit_outlined, size: 15),
                            label: const Text('Edit Card', style: TextStyle(fontSize: 12.5)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Close Preview', style: TextStyle(fontSize: 12.5)),
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
                'Deactivate Card Template',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: kTitleColor,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to deactivate "${card.title}"?',
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
                await repo.deleteCard(card.id);
                ref.invalidate(adminCardsProvider);
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

  void _confirmBatchDeleteCards(BuildContext context) {
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
                'Deactivate Selected Cards',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: kTitleColor,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to deactivate ${_selectedCardIds.length} selected card templates?',
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
                await repo.deleteCardsBatch(_selectedCardIds.toList());
                _selectedCardIds.clear();
                ref.invalidate(adminCardsProvider);
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
    final cardsAsync = ref.watch(adminCardsProvider);
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Action Header Bar Surface
        Container(
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
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Debounced Search Field
                  Container(
                    width: 220,
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
                        hintText: 'Search card title...',
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
                  // Category Filter Dropdown
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: kDashBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kDashBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedCategoryFilter,
                        hint: const Text(
                          'All Categories',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: kLabelColor,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Categories', style: TextStyle(fontSize: 12.5)),
                          ),
                          ...categories.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name, style: const TextStyle(fontSize: 12.5)),
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
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (_selectedCardIds.isNotEmpty) ...[
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
                        '${_selectedCardIds.length} selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _primaryAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmBatchDeleteCards(context),
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
                    message: 'Refresh card list',
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
                      icon: cardsAsync.isLoading || cardsAsync.isRefreshing
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
                      onPressed: () => ref.invalidate(adminCardsProvider),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCardDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text(
                      'Add Card Template',
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
                    color: kDashCardBg,
                    borderRadius: BorderRadius.circular(kCardRadius),
                    border: Border.all(color: kDashBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.style_outlined,
                        size: 44,
                        color: kMutedColor,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No Card Templates Found',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kTitleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _activeSearchQuery.isNotEmpty ||
                                _selectedCategoryFilter != null
                            ? 'No cards match your active filter settings.'
                            : 'Click "Add Card Template" to upload card artwork.',
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
                  : <AdminCard>[];

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
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10.5,
                                            color: kMutedColor,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'FEATURED',
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: kTitleColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Transform.scale(
                                              scale: 0.75,
                                              child: Switch(
                                                value: card.isFeatured,
                                                activeThumbColor: _primaryAccent,
                                                onChanged: (val) async {
                                                  await ref
                                                      .read(adminRepositoryProvider)
                                                      .toggleFeaturedCard(card.id, val);
                                                  ref.invalidate(adminCardsProvider);
                                                },
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
                                                color:
                                                    (card.isActive
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
                                                      color: card.isActive
                                                          ? _success
                                                          : kLabelColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    card.isActive
                                                        ? 'Active'
                                                        : 'Inactive',
                                                    style: TextStyle(
                                                      color: card.isActive
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
                                                Tooltip(
                                                  message: 'Preview Card',
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                                                    icon: const Icon(
                                                      Icons.remove_red_eye_outlined,
                                                      color: _primaryAccent,
                                                      size: 16,
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
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                      color: kLabelColor,
                                                      size: 16,
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
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                                                    icon: const Icon(
                                                      Icons.delete_outline_rounded,
                                                      color: _danger,
                                                      size: 16,
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
                              'Showing ${startIndex + 1} - $endIndex of ${filtered.length} cards',
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
                Center(child: Text('Error loading cards: $err')),
          ),
        ),
      ],
    );
  }
}
