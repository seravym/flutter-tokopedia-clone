import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/product.dart';
import '../../services/wishlist_store.dart';
import '../../services/cart_store.dart';
import '../../widgets/common.dart';
import '../product/product_detail_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Semua', 'Tersedia', 'Diskon', 'Terlaris'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text('Favorit Saya', style: T.h2),
        actions: [
          ListenableBuilder(
            listenable: WishlistStore.instance,
            builder: (context, _) {
              if (WishlistStore.instance.count == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _confirmClearAll(context),
                child: Text('Ubah', style: T.s(14, w: FontWeight.w700, c: AppColors.green)),
              );
            },
          ),
          const SizedBox(width: 8),
          const CartIconButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.bg,
                        border: Border.all(color: isSelected ? AppColors.green : AppColors.line),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _tabs[index],
                        style: T.s(13, w: isSelected ? FontWeight.w700 : FontWeight.w600, c: isSelected ? AppColors.green : AppColors.ink),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.line),
          
          Expanded(
            child: ListenableBuilder(
              listenable: WishlistStore.instance,
              builder: (context, _) {
                var items = WishlistStore.instance.items;
                
                if (_selectedTab == 1) items = items.where((p) => p.inStock).toList();
                if (_selectedTab == 2) items = items.where((p) => p.hasDiscount).toList();
                
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'Wishlist kosong',
                    subtitle: 'Cari barang impianmu dan simpan di sini.',
                    actionLabel: 'Cari Barang',
                    onAction: () => Navigator.pop(context),
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 330, 
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _WishlistCard(product: items[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Hapus Semua?', style: T.h3),
        content: Text('Yakin ingin mengosongkan favorit?', style: T.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: T.s(14, w: FontWeight.w700, c: AppColors.sub))),
          TextButton(
            onPressed: () {
              WishlistStore.instance.clearAll();
              Navigator.pop(ctx);
            },
            child: Text('Hapus', style: T.s(14, w: FontWeight.w800, c: AppColors.green)),
          ),
        ],
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final Product product;
  const _WishlistCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final p = product;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(p.thumbnail, fit: BoxFit.cover),
                  if (p.hasDiscount)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
                        ),
                        child: Text('-${p.discountPercentage.round()}%', style: T.s(11, w: FontWeight.w800, c: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: T.s(13, w: FontWeight.w600, h: 1.2)),
                  const SizedBox(height: 6),
                  Text(rupiahInt(p.finalIdr), style: T.s(15, w: FontWeight.w800, c: AppColors.green)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
                      Text(' ${p.rating.toStringAsFixed(1)}', style: T.s(11, c: AppColors.sub)),
                      const Spacer(),
                      Text('${p.stock}rb+ terjual', style: T.s(11, c: AppColors.sub)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(4)),
                        child: Text('Produk Serupa', style: T.s(11, c: AppColors.sub)),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final res = CartStore.instance.add(p);
                          if (res == AddResult.added) toast(context, 'Masuk keranjang!');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.green),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.shopping_cart_outlined, size: 16, color: AppColors.green),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}