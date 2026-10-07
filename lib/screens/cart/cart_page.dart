import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../services/app_nav.dart';
import '../../services/cart_store.dart';
import '../../services/product_repository.dart';
import '../../widgets/common.dart';
import '../product/product_detail_page.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  final bool showBack;
  final bool embedded;
  const CartPage({super.key, this.showBack = false, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final cart = CartStore.instance;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            return Column(
              children: [
                _header(context, cart),
                Expanded(
                  child: cart.items.isEmpty
                      ? EmptyState(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Keranjangmu masih kosong',
                          subtitle: 'Yuk isi dengan barang-barang lucu yang kamu suka ✨',
                          actionLabel: 'Mulai belanja',
                          onAction: () {
                            Navigator.of(context).popUntil((r) => r.isFirst);
                            AppNav.tab.value = 0;
                          },
                        )
                      : _list(context, cart),
                ),
                if (cart.items.isNotEmpty) _summary(context, cart),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, CartStore cart) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          if (showBack) ...[
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: softShadow(),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text('Keranjang', style: T.h1),
          const SizedBox(width: 10),
          if (cart.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${cart.totalQty}',
                style: T.s(13, w: FontWeight.w800, c: AppColors.green),
              ),
            ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, CartStore cart) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _check(cart.allSelected, (v) => cart.selectAll(v)),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Pilih semua', style: T.s(14, w: FontWeight.w700)),
              ),
              if (cart.selectedItems.isNotEmpty)
                TextButton(
                  onPressed: () => _confirmDeleteSelected(context, cart),
                  child: Text(
                    'Hapus (${cart.selectedItems.length})',
                    style: T.s(13, w: FontWeight.w700, c: AppColors.peach),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final item in List.of(cart.items))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _itemCard(context, cart, item),
          ),
      ],
    );
  }

  Widget _check(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? AppColors.green : const Color(0xFFC6D1CB),
            width: 2,
          ),
        ),
        child: value
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  Widget _itemCard(BuildContext context, CartStore cart, CartItem item) {
    final hasDiscount = item.originalIdr > item.priceIdr;
    return Dismissible(
      key: ValueKey('cart-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.peach,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      onDismissed: (_) {
        final index = cart.items.indexOf(item);
        cart.remove(item);
        toast(
          context,
          'Barang dihapus dari keranjang',
          icon: Icons.delete_outline_rounded,
          actionLabel: 'Batalkan',
          onAction: () => cart.restore(item, index < 0 ? 0 : index),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: softShadow(0.04),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 34, right: 10),
              child: _check(item.selected, (v) => cart.toggle(item, v)),
            ),
            GestureDetector(
              onTap: () => _openProduct(context, item),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 88,
                  height: 88,
                  color: AppColors.mintSoft,
                  child: NetImage(item.thumbnail),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.brand, style: T.small),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: T.s(13, w: FontWeight.w700, h: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rupiahInt(item.priceIdr),
                    style: T.s(15, w: FontWeight.w800, ls: -0.3),
                  ),
                  if (hasDiscount)
                    Text(
                      rupiahInt(item.originalIdr),
                      style: T.s(
                        11,
                        c: AppColors.sub,
                        deco: TextDecoration.lineThrough,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      QtyStepper(
                        value: item.qty,
                        max: item.maxQty,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          cart.setQty(item, v);
                        },
                        onMaxReached: () => toast(
                          context,
                          item.stock < kMaxQtyPerItem
                              ? 'Stok tersisa ${item.stock} barang'
                              : 'Maksimal pembelian $kMaxQtyPerItem barang per produk',
                          icon: Icons.info_outline_rounded,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          final index = cart.items.indexOf(item);
                          cart.remove(item);
                          toast(
                            context,
                            'Barang dihapus dari keranjang',
                            icon: Icons.delete_outline_rounded,
                            actionLabel: 'Batalkan',
                            onAction: () => cart.restore(item, index),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.sub,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.stock <= 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Stok tersisa ${item.stock}',
                        style: T.s(11, w: FontWeight.w700, c: AppColors.peach),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openProduct(BuildContext context, CartItem item) async {
    var p = ProductRepository.instance.byId(item.id);
    if (p == null) {
      try {
        await ProductRepository.instance.all();
        p = ProductRepository.instance.byId(item.id);
      } catch (_) {}
    }
    if (!context.mounted) return;
    if (p == null) {
      toast(
        context,
        'Gagal memuat produk. Cek koneksi internetmu.',
        icon: Icons.wifi_off_rounded,
      );
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: p!)));
  }

  Future<void> _confirmDeleteSelected(
    BuildContext context,
    CartStore cart,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus barang?', style: T.h3),
        content: Text(
          '${cart.selectedItems.length} barang terpilih akan dihapus dari keranjang.',
          style: T.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: T.s(14, w: FontWeight.w700, c: AppColors.sub),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus',
              style: T.s(14, w: FontWeight.w800, c: AppColors.peach),
            ),
          ),
        ],
      ),
    );
    if (ok == true) cart.removeSelected();
  }

  Widget _summary(BuildContext context, CartStore cart) {
    final bottom = embedded ? 0.0 : MediaQuery.of(context).padding.bottom;
    final enabled = cart.selectedQty > 0;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total harga', style: T.small),
                const SizedBox(height: 2),
                Text(
                  rupiahInt(cart.subtotal),
                  style: T.s(20, w: FontWeight.w800, ls: -0.6),
                ),
                if (cart.savings > 0)
                  Text(
                    'Hemat ${rupiahInt(cart.savings)}',
                    style: T.s(12, w: FontWeight.w700, c: AppColors.green),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 168,
            child: PrimaryButton(
              label: 'Checkout (${cart.selectedQty})',
              onPressed: enabled
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CheckoutPage()),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
