import 'package:flutter/material.dart';

import '../../core/format.dart';
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
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.mint,
                  child: Icon(
                    Icons.storefront_outlined,
                    size: 34,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.displayBrand} Official Store',
                        style: T.s(18, w: FontWeight.w800),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Toko resmi ${product.displayBrand}',
                        style: T.small,
                      ),
                      const SizedBox(height: 8),
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
                          const SizedBox(width: 12),
                          Text('${products.length + 1} Produk', style: T.small),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Judul produk
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text('Produk dari Toko', style: T.h3),
          ),

          // Produk
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final item = index == 0 ? product : products[index - 1];

                return ProductCard(product: item);
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
