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
            ],
          );
        },
      ),
    );
  }
}

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