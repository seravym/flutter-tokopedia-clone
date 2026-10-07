import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/app_colors.dart';
import '../../models/product.dart';
import '../../services/product_repository.dart';
import '../../services/saved_folders_repository.dart';
import '../../widgets/product_card.dart';
import '../../widgets/save_to_folder_sheet.dart';
import '../saved/saved_screen.dart';
import '../orders/order_history_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isSearchExpanded = false;

  late Future<List<Product>> _productsFuture;

  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _autoScrollTimer;

  final List<Map<String, dynamic>> banners = [
    {
      'title': 'Koleksi Terbaru',
      'subtitle': 'Diskon hingga 70% untuk item pilihan',
      'color': AppColors.accent,
      'icon': Icons.auto_awesome,
    },
    {
      'title': 'Gratis Ongkir',
      'subtitle': 'Min. belanja Rp50.000 ke seluruh Indonesia',
      'color': const Color(0xFF2C2C3E),
      'icon': Icons.local_shipping_outlined,
    },
    {
      'title': 'Cashback Eksklusif',
      'subtitle': 'Hingga 20% dengan metode pembayaran digital',
      'color': const Color(0xFF3E3E52),
      'icon': Icons.account_balance_wallet_outlined,
    },
  ];

  final List<Map<String, dynamic>> categories = [
    {'name': 'Elektronik', 'icon': Icons.devices_other},
    {'name': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'Makanan', 'icon': Icons.restaurant},
    {'name': 'Kesehatan', 'icon': Icons.medical_services_outlined},
    {'name': 'Olahraga', 'icon': Icons.sports_tennis},
    {'name': 'Otomotif', 'icon': Icons.directions_car_outlined},
  ];

  final List<Map<String, dynamic>> promos = [
    {
      'title': 'Flash Sale',
      'desc': 'Diskon hingga 90% — berakhir tengah malam',
      'tag': 'TERBATAS',
      'icon': Icons.bolt,
    },
    {
      'title': 'Voucher Belanja',
      'desc': 'Klaim kupon eksklusif senilai Rp50.000',
      'tag': 'VOUCHER',
      'icon': Icons.confirmation_number_outlined,
    },
    {
      'title': 'Cashback Spesial',
      'desc': 'Untuk pengguna baru dan transaksi pertama',
      'tag': 'NEW USER',
      'icon': Icons.card_giftcard,
    },
    {
      'title': 'Bundling Hemat',
      'desc': 'Beli 2 gratis 1 untuk kategori terpilih',
      'tag': 'BUNDLING',
      'icon': Icons.inventory_2_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductRepository.instance.all();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final nextPage = (_currentBannerIndex + 1) % banners.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    if (_currentIndex == 0) {
      return AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isSearchExpanded
                  ? MediaQuery.of(context).size.width * 0.60
                  : 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    setState(() => _isSearchExpanded = !_isSearchExpanded);
                  },
                  onHover: (isHovering) {
                    setState(() => _isSearchExpanded = isHovering);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.muted,
                          size: 20,
                        ),
                        if (_isSearchExpanded) ...[
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Cari produk',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 13.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.muted,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 18,
                            width: 1,
                            color: AppColors.border,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.muted,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.ink,
              size: 22,
            ),
          ),
          AnimatedBuilder(
            animation: SavedFoldersRepository.instance,
            builder: (context, _) {
              final count = SavedFoldersRepository.instance.totalCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedScreen()),
                      );
                    },
                    icon: const Icon(
                      Icons.bookmark_border,
                      color: AppColors.ink,
                      size: 22,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () => setState(() => _currentIndex = 2),
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.ink,
              size: 22,
            ),
          ),
        ],
      );
    }

    String title;
    switch (_currentIndex) {
      case 1:
        title = 'Promo';
        break;
      case 2:
        title = 'Keranjang';
        break;
      case 3:
        title = 'Pengaturan';
        break;
      case 4:
        title = 'Akun';
        break;
      default:
        title = 'Tokopedia';
    }

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),
      actions: _currentIndex == 2
          ? []
          : [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none,
                  color: AppColors.ink,
                  size: 22,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _currentIndex = 2),
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.ink,
                  size: 22,
                ),
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: GNav(
              backgroundColor: Colors.transparent,
              color: AppColors.muted,
              activeColor: AppColors.ink,
              tabBackgroundColor: AppColors.bg,
              rippleColor: AppColors.bg,
              hoverColor: AppColors.bg,
              gap: 6,
              selectedIndex: _currentIndex,
              onTabChange: (index) => setState(() => _currentIndex = index),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              duration: const Duration(milliseconds: 300),
              tabBorderRadius: 14,
              curve: Curves.easeInOutCubic,
              tabs: const [
                GButton(icon: Icons.home_outlined, text: 'Home'),
                GButton(icon: Icons.local_offer_outlined, text: 'Promo'),
                GButton(icon: Icons.shopping_bag_outlined, text: 'Cart'),
                GButton(icon: Icons.tune_outlined, text: 'Settings'),
                GButton(icon: Icons.person_outline, text: 'Account'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildPromoContent();
      case 2:
        return const Center(child: Text('Halaman Keranjang'));
      case 3:
        return const Center(child: Text('Halaman Pengaturan'));
      case 4:
        return _buildAccountContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildAccountContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Akun Saya',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Icon(Icons.person_outline, size: 28),
              ),
              SizedBox(width: 14),
              Text(
                'Pengguna Tokopedia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.receipt_long_outlined, color: AppColors.ink),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Riwayat Pesanan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent2.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SPESIAL',
                      style: TextStyle(
                        color: AppColors.accent2,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Promo Pilihan\nMinggu Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kurasi penawaran terbaik untukmu',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Penawaran Aktif',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: promos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening: ${promo['title']}'),
                        backgroundColor: AppColors.accent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            promo['icon'],
                            color: AppColors.ink,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo['tag'],
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                promo['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.5,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                promo['desc'],
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.muted,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _productsFuture = ProductRepository.instance.all(refresh: true);
    });
    await _productsFuture;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beranda diperbarui'),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildHomeContent() {
    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      showChildOpacityTransition: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 170,
              child: PageView.builder(
                controller: _bannerController,
                onPageChanged: (index) {
                  setState(() => _currentBannerIndex = index);
                },
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: banner['color'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                banner['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.4,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                banner['subtitle'],
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Icon(
                            banner['icon'],
                            color: AppColors.accent2,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SmoothPageIndicator(
                controller: _bannerController,
                count: banners.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 5,
                  dotWidth: 5,
                  expansionFactor: 3,
                  activeDotColor: AppColors.accent,
                  dotColor: AppColors.border,
                  spacing: 6,
                ),
                onDotClicked: (index) {
                  _bannerController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${cat['name']}'),
                            backgroundColor: AppColors.accent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Icon(
                              cat['icon'],
                              color: AppColors.ink,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['name'],
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.ink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Untuk Kamu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 14),
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Gagal memuat: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _handleRefresh,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('Belum ada produk')),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 320,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _SavableProductWrapper(
                      product: product,
                      child: ProductCard(product: product),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SavableProductWrapper extends StatelessWidget {
  final Product product;
  final Widget child;

  const _SavableProductWrapper({required this.product, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: 8,
          right: 8,
          child: AnimatedBuilder(
            animation: SavedFoldersRepository.instance,
            builder: (context, _) {
              final isSaved = SavedFoldersRepository.instance.isSavedAnywhere(
                product.id,
              );
              return GestureDetector(
                onTap: () {
                  SaveToFolderSheet.show(context, product);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSaved ? AppColors.accent2 : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: isSaved ? Colors.white : AppColors.ink,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
