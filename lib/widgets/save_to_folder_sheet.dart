import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/product.dart';
import '../services/saved_folders_repository.dart';

class SaveToFolderSheet extends StatefulWidget {
  final Product product;
  const SaveToFolderSheet({super.key, required this.product});

  static Future<void> show(BuildContext context, Product product) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveToFolderSheet(product: product),
    );
  }

  @override
  State<SaveToFolderSheet> createState() => _SaveToFolderSheetState();
}

class _SaveToFolderSheetState extends State<SaveToFolderSheet> {
  final _nameCtrl = TextEditingController();
  bool _showCreateField = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SavedFoldersRepository.instance,
      builder: (context, _) {
        final folders = SavedFoldersRepository.instance.folders;
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    children: [
                      Text(
                        'Simpan ke...',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      final isSaved = SavedFoldersRepository.instance
                          .isInFolder(folder.id, widget.product.id);
                      return ListTile(
                        onTap: () {
                          SavedFoldersRepository.instance
                              .toggleInFolder(folder.id, widget.product);
                        },
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            folder.id == 'default'
                                ? Icons.bookmarks_outlined
                                : Icons.folder_outlined,
                            color: AppColors.ink,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          folder.name,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${folder.count} produk',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        trailing: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSaved
                                ? AppColors.accent2
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSaved
                                  ? AppColors.accent2
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: isSaved
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                if (_showCreateField)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameCtrl,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Nama folder...',
                              hintStyle: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13.5,
                              ),
                              filled: true,
                              fillColor: AppColors.bg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 14,
                            ),
                            onSubmitted: (_) => _createFolder(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _createFolder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ink,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Buat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListTile(
                    onTap: () => setState(() => _showCreateField = true),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.ink,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      'Buat folder baru',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createFolder() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final folder = SavedFoldersRepository.instance.createFolder(name);
    SavedFoldersRepository.instance.toggleInFolder(folder.id, widget.product);
    _nameCtrl.clear();
    setState(() => _showCreateField = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Folder "$name" dibuat'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
      ),
    );
  }
}