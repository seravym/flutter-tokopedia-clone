import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../common.dart';

class ProductSearchSkeleton extends StatelessWidget {
  const ProductSearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: 310,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.line),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Skeleton(radius: 12),
                  ),
                  const SizedBox(height: 12),
                  const Skeleton(height: 16, width: double.infinity, radius: 4),
                  const SizedBox(height: 6),
                  const Skeleton(height: 16, width: 120, radius: 4),
                  const SizedBox(height: 16),
                  const Skeleton(height: 22, width: 140, radius: 4),
                ],
              ),
            );
          },
          childCount: 6,
        ),
      ),
    );
  }
}