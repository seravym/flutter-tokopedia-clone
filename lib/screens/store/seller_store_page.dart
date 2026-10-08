import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/product.dart';
import '../../services/product_repository.dart';
import '../../widgets/product_card.dart';

class SellerStorePage extends StatelessWidget {
  final Product product;

  const SellerStorePage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final repo = ProductRepository.instance;
    final products = repo.related(product);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Toko Seller'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Informasi toko
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.mint,
                        child: Icon(
                          Icons.storefront_outlined,
                          size: 32,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${product.displayBrand} Official Store',
                                    style: T.s(17, w: FontWeight.w800),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.mint,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Official',
                                    style: T.s(
                                      10,
                                      w: FontWeight.w700,
                                      c: AppColors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Toko resmi ${product.displayBrand}',
                              style: T.small,
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: AppColors.star,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: T.s(13, w: FontWeight.w700),
                                ),
                                const SizedBox(width: 14),
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 15,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${products.length + 1} Produk',
                                  style: T.small,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Judul produk
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Text('Produk dari Toko', style: T.h3),
                    const Spacer(),
                    Text('${products.length + 1} produk', style: T.small),
                  ],
                ),
              ),
            ),
          ),

          // Produk
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final item = index == 0 ? product : products[index - 1];

                    return ProductCard(product: item);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
