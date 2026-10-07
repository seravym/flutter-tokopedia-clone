import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/saved_folders_repository.dart';
import 'folder_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const Text(
          'Simpanan',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: SavedFoldersRepository.instance,
        builder: (context, _) {
          final folders = SavedFoldersRepository.instance.folders;
          final nonEmpty = folders.where((f) => f.count > 0).toList();
          final empty = folders.where((f) => f.count == 0).toList();
          final ordered = [...nonEmpty, ...empty];

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent2.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${folders.length} FOLDER',
                          style: const TextStyle(
                            color: AppColors.accent2,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${SavedFoldersRepository.instance.totalCount} produk',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final folder = ordered[index];
                      return _FolderCard(folder: folder);
                    },
                    childCount: ordered.length,
                  ),
                ),
              ),
              // Ruang ekstra biar FAB gak nutupin folder terakhir
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),

      // ✅ FAB BUAT FOLDER BARU
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateFolderDialog(context),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Folder Baru',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DIALOG BUAT FOLDER BARU
  // ==========================================
  void _showCreateFolderDialog(BuildContext context) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Folder baru',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Beri nama folder sesuai isinya',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Misal: Idol, Makanan, Wishlist',
                  hintStyle: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: AppColors.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (value) {
                  _createFolder(context, dialogContext, value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
            TextButton(
              onPressed: () {
                _createFolder(context, dialogContext, ctrl.text);
              },
              child: const Text(
                'Buat',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _createFolder(
    BuildContext context,
    BuildContext dialogContext,
    String name,
  ) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama folder tidak boleh kosong'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Cek duplikat (case-insensitive)
    final exists = SavedFoldersRepository.instance.folders.any(
      (f) => f.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Folder "$trimmed" sudah ada'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    SavedFoldersRepository.instance.createFolder(trimmed);
    Navigator.pop(dialogContext);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Folder "$trimmed" dibuat'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ==========================================
// CARD FOLDER
// ==========================================
class _FolderCard extends StatelessWidget {
  final dynamic folder;
  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FolderDetailScreen(folderId: folder.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
              const Spacer(),
              Text(
                folder.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${folder.count} produk',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}