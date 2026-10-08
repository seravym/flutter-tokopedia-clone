import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../screens/product/product_detail_page.dart';
import 'common.dart';

void openProduct(BuildContext context, Product p) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
  );
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final p = product;
    return GestureDetector(
      onTap: () => openProduct(context, p),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: softShadow(0.05),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.mintSoft,
                    child: NetImage(p.images.isNotEmpty ? p.images.first : p.thumbnail, fit: BoxFit.cover),
                  ),
                  if (!p.inStock)
                    Container(
                      color: Colors.white.withValues(alpha: 0.7),
                      alignment: Alignment.center,
                      child: Text('Stok habis',
                          style: T.s(13, w: FontWeight.w800)),
                    ),
                  if (p.fastShipping)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lilac,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                size: 12, color: Colors.white),
                            Text('Kilat',
                                style: T.s(10,
                                    w: FontWeight.w800, c: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: T.s(13, w: FontWeight.w600, h: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(rupiahInt(p.finalIdr),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: T.s(15, w: FontWeight.w800, ls: -0.3)),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 18,
                    child: p.hasDiscount
                        ? Row(
                            children: [
                              DiscountBadge(p.discountPercentage),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  rupiahInt(p.originalIdr),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: T.s(11,
                                      c: AppColors.sub,
                                      deco: TextDecoration.lineThrough),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 15, color: AppColors.star),
                      const SizedBox(width: 2),
                      Text(p.rating.toStringAsFixed(1),
                          style: T.s(12, w: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          p.displayBrand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: T.small,
                        ),
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
  }
}

const SliverGridDelegate productGridDelegate =
    SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 14,
  crossAxisSpacing: 14,
  mainAxisExtent: 310,
);
