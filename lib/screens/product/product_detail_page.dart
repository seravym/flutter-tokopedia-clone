import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/product.dart';
import '../../services/app_nav.dart';
import '../../services/cart_store.dart';
import '../../services/product_repository.dart';
import '../../widgets/common.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pager = PageController();
  int _imgIndex = 0;
  int _qty = 1;
  bool _descOpen = false;

  Product get p => widget.product;

  @override
  void initState() {
    super.initState();
    _qty = p.minOrder.clamp(1, p.maxQty < 1 ? 1 : p.maxQty).toInt();
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _addToCart() {
    HapticFeedback.lightImpact();
    final r = CartStore.instance.add(p, qty: _qty);
    setState(() {});
    switch (r) {
      case AddResult.outOfStock:
        toast(context, 'Maaf, stok produk ini habis',
            icon: Icons.error_outline_rounded);
        break;
      case AddResult.reachedLimit:
        toast(context,
            'Jumlah di keranjang sudah mencapai batas (${p.maxQty} barang)',
            icon: Icons.info_outline_rounded,
            actionLabel: 'Lihat',
            onAction: _openCart);
        break;
      case AddResult.added:
        toast(context, '$_qty barang masuk keranjang',
            actionLabel: 'Lihat', onAction: _openCart);
        break;
    }
  }

  void _buyNow() {
    final r = CartStore.instance.add(p, qty: _qty, exclusive: true);
    if (r == AddResult.outOfStock) {
      toast(context, 'Maaf, stok produk ini habis',
          icon: Icons.error_outline_rounded);
      return;
    }
    _openCart();
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CartPage(showBack: true)),
    );
  }

  void _openGallery(int start) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) =>
            _FullscreenGallery(images: p.images, start: start),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProductRepository.instance;
    final siblings = repo.siblings(p);
    final related = repo.related(p);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          _buildGalleryAppBar(),
          if (p.images.length > 1) SliverToBoxAdapter(child: _thumbs()),
          SliverToBoxAdapter(child: _priceCard()),
          if (siblings.isNotEmpty)
            SliverToBoxAdapter(child: _variantCard(siblings)),
          SliverToBoxAdapter(child: _qtyCard()),
          SliverToBoxAdapter(child: _descriptionCard()),
          SliverToBoxAdapter(child: _specCard()),
          SliverToBoxAdapter(child: _reviewCard()),
          if (related.isNotEmpty)
            SliverToBoxAdapter(child: _relatedSection(related)),
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }


  Widget _circleBtn(IconData icon, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.all(6),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: softShadow(0.12),
            ),
            child: Icon(icon, color: AppColors.ink, size: 20),
          ),
        ),
      );

  Widget _buildGalleryAppBar() {
    final h = MediaQuery.of(context).size.width.clamp(300.0, 480.0).toDouble();
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      expandedHeight: h + 20,
      leading: _circleBtn(
          Icons.arrow_back_ios_new_rounded, () => Navigator.of(context).pop()),
      actions: [
        _circleBtn(Icons.search_rounded, () {
          Navigator.of(context).popUntil((r) => r.isFirst);
          AppNav.openSearch();
        }),
        const Padding(
          padding: EdgeInsets.only(right: 12, left: 4),
          child: Center(child: CartIconButton()),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          color: AppColors.mintSoft,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pager,
                itemCount: p.images.length,
                onPageChanged: (i) => setState(() => _imgIndex = i),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _openGallery(i),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 56, bottom: 8),
                    child: NetImage(p.images[i], fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_outlined,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('${_imgIndex + 1}/${p.images.length}',
                          style: T.s(12, w: FontWeight.w700, c: Colors.white)),
                    ],
                  ),
                ),
              ),
              if (!p.inStock)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.6),
                    alignment: Alignment.center,
                    child: Text('Stok habis', style: T.h2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbs() {
    return Container(
      color: Colors.white,
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
        itemCount: p.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final sel = i == _imgIndex;
          return GestureDetector(
            onTap: () => _pager.animateToPage(i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 62,
              decoration: BoxDecoration(
                color: AppColors.mintSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? AppColors.green : Colors.transparent,
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: NetImage(p.images[i], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }


  Widget _card({required Widget child, EdgeInsets? margin, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.only(top: 10),
      padding: padding ?? const EdgeInsets.all(18),
      decoration: const BoxDecoration(color: Colors.white),
      child: child,
    );
  }

  Widget _sectionTitle(String t, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Expanded(child: Text(t, style: T.h3)),
            if (trailing != null) trailing,
          ],
        ),
      );

  Widget _priceCard() {
    final reviewCount = p.reviews.length;
    return _card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(rupiahInt(p.finalIdr),
                    style: T.s(28, w: FontWeight.w800, ls: -1)),
              ),
              if (p.hasDiscount) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: DiscountBadge(p.discountPercentage),
                ),
              ],
            ],
          ),
          if (p.hasDiscount)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(rupiahInt(p.originalIdr),
                  style: T.s(13,
                      c: AppColors.sub, deco: TextDecoration.lineThrough)),
            ),
          const SizedBox(height: 12),
          Text(p.title, style: T.s(17, w: FontWeight.w700, h: 1.35)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Pill(
                '${p.rating.toStringAsFixed(1)}'
                '${reviewCount > 0 ? ' • $reviewCount ulasan' : ''}',
                icon: Icons.star_rounded,
                bg: const Color(0xFFFFF5DD),
                fg: const Color(0xFFB77900),
              ),
              Pill(kategoriLabel(p.category),
                  bg: AppColors.lilacSoft,
                  fg: AppColors.lilac,
                  onTap: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    AppNav.openSearch(category: p.category);
                  }),
              if (p.fastShipping)
                const Pill('Pengiriman kilat',
                    icon: Icons.bolt_rounded,
                    bg: AppColors.lilacSoft,
                    fg: AppColors.lilac),
              if (p.inStock)
                Pill(
                  p.stock <= 10 ? 'Sisa ${p.stock}! Buruan 🔥' : 'Stok ${p.stock}',
                  bg: p.stock <= 10 ? AppColors.peachSoft : AppColors.mint,
                  fg: p.stock <= 10 ? AppColors.peach : AppColors.green,
                )
              else
                const Pill('Stok habis',
                    bg: AppColors.peachSoft, fg: AppColors.peach),
            ],
          ),
          if (p.tags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.tags
                  .map((t) => Pill('#$t',
                      bg: AppColors.bg,
                      fg: AppColors.sub,
                      onTap: () {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                        AppNav.openSearch(tag: t);
                      }))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }


  Widget _variantCard(List<Product> siblings) {
    final all = [p, ...siblings];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Varian', trailing: Text(p.displayBrand, style: T.small)),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: all.map((v) {
              final sel = v.id == p.id;
              return GestureDetector(
                onTap: sel
                    ? null
                    : () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => ProductDetailPage(product: v)),
                        ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.mint : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: sel ? AppColors.green : AppColors.line,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: NetImage(v.thumbnail),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(v.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: T.s(12,
                                    w: FontWeight.w700,
                                    c: sel ? AppColors.green : AppColors.ink)),
                            Text(rupiahInt(v.finalIdr),
                                style: T.s(11, c: AppColors.sub)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


  Widget _qtyCard() {
    final inCart = CartStore.instance.qtyOf(p.id);
    final max = p.maxQty < 1 ? 1 : p.maxQty;
    return _card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jumlah', style: T.h3),
                const SizedBox(height: 4),
                Text(
                  p.inStock
                      ? 'Maks. beli ${p.maxQty}'
                          '${p.minOrder > 1 ? ' • Min. ${p.minOrder}' : ''}'
                          '${inCart > 0 ? ' • di keranjang: $inCart' : ''}'
                      : 'Stok sedang habis',
                  style: T.small,
                ),
              ],
            ),
          ),
          Opacity(
            opacity: p.inStock ? 1 : 0.4,
            child: IgnorePointer(
              ignoring: !p.inStock,
              child: QtyStepper(
                value: _qty,
                min: p.minOrder.clamp(1, max).toInt(),
                max: max,
                onChanged: (v) => setState(() => _qty = v),
                onMaxReached: () => toast(
                    context, 'Maksimal pembelian ${p.maxQty} barang',
                    icon: Icons.info_outline_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _descriptionCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Deskripsi Produk'),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: Text(
              p.description,
              maxLines: _descOpen ? null : 4,
              overflow: _descOpen ? TextOverflow.visible : TextOverflow.ellipsis,
              style: T.s(14, h: 1.6, c: const Color(0xFF3B4741)),
            ),
          ),
          if (p.description.length > 160)
            GestureDetector(
              onTap: () => setState(() => _descOpen = !_descOpen),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _descOpen ? 'Tampilkan lebih sedikit' : 'Baca selengkapnya',
                  style: T.s(13, w: FontWeight.w700, c: AppColors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _specCard() {
    final rows = <List<String>>[
      ['Brand', p.displayBrand],
      ['Kategori', kategoriLabel(p.category)],
      ['SKU', p.sku],
      ['Ketersediaan', p.availability],
      ['Garansi', p.warranty],
      ['Pengiriman', p.shipping],
      ['Kebijakan retur', p.returnPolicy],
      ['Min. pembelian', '${p.minOrder} barang'],
    ];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Spesifikasi'),
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                border: i == rows.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 124,
                    child: Text(rows[i][0], style: T.small),
                  ),
                  Expanded(
                    child: Text(rows[i][1],
                        style: T.s(13, w: FontWeight.w600, h: 1.4)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


  Widget _reviewCard() {
    final reviews = p.reviews;
    final counts = List<int>.filled(6, 0);
    for (final r in reviews) {
      if (r.rating >= 1 && r.rating <= 5) counts[r.rating]++;
    }
    final maxCount = counts.fold<int>(1, (a, b) => b > a ? b : a);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Ulasan Pembeli'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(p.rating.toStringAsFixed(1),
                          style: T.s(40, w: FontWeight.w800, ls: -1.5, h: 1)),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 2),
                        child: Text('/5', style: T.small),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stars(p.rating.round(), size: 16),
                  const SizedBox(height: 6),
                  Text('${reviews.length} ulasan', style: T.small),
                ],
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  children: [
                    for (var s = 5; s >= 1; s--)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Text('$s', style: T.s(12, w: FontWeight.w700)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded,
                                size: 12, color: AppColors.star),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: counts[s] / maxCount,
                                  minHeight: 6,
                                  backgroundColor: AppColors.line,
                                  valueColor: const AlwaysStoppedAnimation(
                                      AppColors.green),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 22,
                              child: Text('${counts[s]}',
                                  textAlign: TextAlign.right,
                                  style: T.small),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (reviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('Belum ada ulasan untuk produk ini.',
                  textAlign: TextAlign.center, style: T.small),
            )
          else
            for (final r in reviews) _reviewTile(r),
        ],
      ),
    );
  }

  Widget _reviewTile(Review r) {
    final colors = [
      AppColors.mint,
      AppColors.lilacSoft,
      AppColors.peachSoft,
      const Color(0xFFFFF5DD),
    ];
    final fg = [
      AppColors.green,
      AppColors.lilac,
      AppColors.peach,
      const Color(0xFFB77900),
    ];
    final ci = r.reviewerName.hashCode.abs() % colors.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors[ci],
                child: Text(
                  r.reviewerName.isEmpty ? '?' : r.reviewerName[0].toUpperCase(),
                  style: T.s(14, w: FontWeight.w800, c: fg[ci]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.reviewerName, style: T.s(13, w: FontWeight.w700)),
                    if (r.date != null)
                      Text(tanggal(r.date!.toLocal()), style: T.small),
                  ],
                ),
              ),
              Stars(r.rating, size: 15),
            ],
          ),
          if (r.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(r.comment, style: T.s(13, h: 1.5, c: const Color(0xFF3B4741))),
          ],
        ],
      ),
    );
  }


  Widget _relatedSection(List<Product> related) {
    return _card(
      padding: const EdgeInsets.only(top: 18, bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _sectionTitle('Produk Serupa'),
          ),
          SizedBox(
            height: 310,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              itemCount: related.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => SizedBox(
                width: 170,
                child: ProductCard(product: related[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
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
            child: PrimaryButton(
              label: '+ Keranjang',
              outlined: true,
              onPressed: p.inStock ? _addToCart : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: 'Beli Langsung',
              onPressed: p.inStock ? _buyNow : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  final List<String> images;
  final int start;
  const _FullscreenGallery({required this.images, required this.start});

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _c = PageController(initialPage: widget.start);
  late int _i = widget.start;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _c,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(child: NetImage(widget.images[i], fit: BoxFit.contain)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  Text('${_i + 1}/${widget.images.length}',
                      style: T.s(14, w: FontWeight.w700, c: Colors.white)),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
