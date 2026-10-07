import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/saved_folders_repository.dart';
import '../../widgets/product_card.dart';

class FolderDetailScreen extends StatelessWidget {
  final String folderId;
  const FolderDetailScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SavedFoldersRepository.instance,
      builder: (context, _) {
        final folder = SavedFoldersRepository.instance.folders
            .firstWhere((f) => f.id == folderId);
        final isDefault = folder.id == 'default';

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: AppColors.ink),
            title: Text(
              folder.name,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              if (!isDefault)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.ink),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) async {
                    if (value == 'rename') {
                      await _showRenameDialog(context, folder);
                    } else if (value == 'delete') {
                      await _showDeleteDialog(context);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text('Ganti nama'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Hapus folder',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: folder.products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open_outlined,
                          size: 56, color: AppColors.muted),
                      SizedBox(height: 16),
                      Text(
                        'Folder kosong',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Simpan produk ke folder ini',
                        style: TextStyle(
                            color: AppColors.muted, fontSize: 12.5),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 320,
                  ),
                  itemCount: folder.products.length,
                  itemBuilder: (context, index) {
                    final product = folder.products[index];
                    return Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned.fill(
                          child: ProductCard(product: product),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              SavedFoldersRepository.instance
                                  .toggleInFolder(folder.id, product);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _showRenameDialog(
      BuildContext context, dynamic folder) async {
    final ctrl = TextEditingController(text: folder.name);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Ganti nama folder',
          style: TextStyle(color: AppColors.ink, fontSize: 16),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nama baru',
            filled: true,
            fillColor: AppColors.bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, ctrl.text.trim()),
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      SavedFoldersRepository.instance.renameFolder(folder.id, result);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus folder?',
          style: TextStyle(color: AppColors.ink, fontSize: 16),
        ),
        content: const Text(
          'Semua produk di dalam folder ini akan dihapus.',
          style: TextStyle(color: AppColors.muted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      SavedFoldersRepository.instance.deleteFolder(folderId);
      Navigator.pop(context);
    }
  }
}