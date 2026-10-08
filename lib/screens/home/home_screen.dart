import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/app_colors.dart';
import '../../core/format.dart';
import '../../models/product.dart';
import '../../services/product_repository.dart';
import '../../services/saved_folders_repository.dart';
import '../../services/budget_repository.dart';
import '../../services/app_nav.dart';
import '../../widgets/product_card.dart';
import '../../widgets/save_to_folder_sheet.dart';
import '../../widgets/image_search_sheet.dart';
import '../saved/saved_screen.dart';
import '../account/account_screen.dart';
import '../budget/budget_screen.dart';
import '../search/search_screen.dart';
import '../cart/cart_page.dart';
import '../settings/settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showSearch = false;
  DateTime? _lastRefreshTime;

  final ScrollController _promoScrollController = ScrollController();
  final List<GlobalKey> _promoSectionKeys =
      List.generate(3, (_) => GlobalKey());
  int? _pendingPromoSection;

  late Future<List<Product>> _productsFuture;

  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _autoScrollTimer;

  final List<Map<String, dynamic>> banners = [
    {
      'title': 'Flash Sale',
      'subtitle': 'Diskon terbesar hari ini',
      'color': AppColors.accent,
      'icon': Icons.bolt,
      'targetSection': 0,
    },
    {
      'title': 'Diskon Spesial',
      'subtitle': 'Penawaran pilihan untukmu',
      'color': const Color(0xFF2C2C3E),
      'icon': Icons.local_offer_outlined,
      'targetSection': 1,
    },
    {
      'title': 'Hemat',
      'subtitle': 'Tetap hemat tetap gaya',
      'color': const Color(0xFF3E3E52),
      'icon': Icons.savings_outlined,
      'targetSection': 2,
    },
  ];

  final List<Map<String, dynamic>> categories = [
    {'name': 'Smartphone', 'slug': 'smartphones', 'icon': Icons.smartphone},
    {'name': 'Laptop', 'slug': 'laptops', 'icon': Icons.laptop_mac},
    {'name': 'Kecantikan', 'slug': 'beauty', 'icon': Icons.spa_outlined},
    {'name': 'Fashion', 'slug': 'womens-dresses', 'icon': Icons.checkroom},
    {'name': 'Pria', 'slug': 'mens-shirts', 'icon': Icons.man_outlined},
    {
      'name': 'Olahraga',
      'slug': 'sports-accessories',
      'icon': Icons.sports_tennis,
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
    _promoScrollController.dispose();
    super.dispose();
  }

  void _openSearch({String? category, String? query, String? tag}) {
    AppNav.searchIntent.value = SearchIntent(
      category: category,
      query: query,
      tag: tag,
    );
    setState(() => _showSearch = true);
  }

  void _closeSearch() {
    setState(() => _showSearch = false);
  }

  void _openPromoSection(int sectionIndex) {
    setState(() {
      _currentIndex = 1;
      _showSearch = false;
      _pendingPromoSection = sectionIndex;
    });
  }

  void _scrollToPendingPromoSection() {
    final target = _pendingPromoSection;
    if (target == null) return;
    _pendingPromoSection = null;
    final ctx = _promoSectionKeys[target].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openImageSearch() {
    showImageSearchSheet(
      context,
      onSelect: ({String? category, String? query}) {
        if (!mounted) return;
        _openSearch(category: category, query: query);
      },
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_showSearch) return null;
    if (_currentIndex == 2) return null;
    if (_currentIndex == 4) return null;

    if (_currentIndex == 0) {
      return AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Expanded(
              child: Container(
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
                    onTap: () => _openSearch(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.muted,
                            size: 20,
                          ),
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
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _openImageSearch,
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.muted,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            height: 18,
                            width: 1,
                            color: AppColors.border,
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Fitur scan barcode segera hadir',
                                  ),
                                  backgroundColor: AppColors.accent,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: AppColors.muted,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
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
            animation: BudgetRepository.instance,
            builder: (context, _) {
              final repo = BudgetRepository.instance;
              final isOver = repo.isOverBudget;
              final hasBudget = repo.hasBudget;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BudgetScreen()),
                      );
                    },
                    icon: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.ink,
                      size: 22,
                    ),
                  ),
                  if (hasBudget && isOver)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
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
      case 3:
        title = 'Pengaturan';
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
      actions: [
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
    return PopScope(
      canPop: !_showSearch,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: Container(
        color: AppColors.accent,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: GNav(
              backgroundColor: AppColors.accent,
              color: Colors.grey,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.white.withValues(alpha: 0.12),
              rippleColor: Colors.white.withValues(alpha: 0.1),
              hoverColor: Colors.white.withValues(alpha: 0.08),
              gap: 6,
              selectedIndex: _currentIndex,
              onTabChange: (index) => setState(() {
                _currentIndex = index;
                _showSearch = false;
              }),
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
      ),
    );
  }

  Widget _buildBody() {
    if (_showSearch) {
      return SearchScreen(onClose: _closeSearch);
    }

    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildPromoContent();
      case 2:
        return const CartPage(embedded: true);
      case 3:
        return const SettingsPage();
      case 4:
        return const AccountScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildPromoContent() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 2,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat: ${snapshot.error}'));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToPendingPromoSection();
        });

        final allProducts = snapshot.data ?? [];
        final sorted = List<Product>.from(
          allProducts,
        )..sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));

        final discounted = sorted
            .where((p) => p.discountPercentage > 0)
            .toList();

        final total = discounted.length;
        final chunk = (total / 3).ceil();

        final flashSale = discounted.take(chunk).toList();
        final diskonSpesial = discounted.skip(chunk).take(chunk).toList();
        final hemat = discounted.skip(chunk * 2).take(chunk).toList();

        return SingleChildScrollView(
          controller: _promoScrollController,
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
              if (flashSale.isNotEmpty)
                _promoSection(
                  sectionKey: _promoSectionKeys[0],
                  title: 'Flash Sale',
                  subtitle:
                      'Diskon ${flashSale.last.discountPercentage.round()}% - '
                      '${flashSale.first.discountPercentage.round()}%',
                  icon: Icons.bolt,
                  products: flashSale,
                ),
              if (diskonSpesial.isNotEmpty)
                _promoSection(
                  sectionKey: _promoSectionKeys[1],
                  title: 'Diskon Spesial',
                  subtitle:
                      'Diskon ${diskonSpesial.last.discountPercentage.round()}% - '
                      '${diskonSpesial.first.discountPercentage.round()}%',
                  icon: Icons.local_offer_outlined,
                  products: diskonSpesial,
                ),
              if (hemat.isNotEmpty)
                _promoSection(
                  sectionKey: _promoSectionKeys[2],
                  title: 'Hemat',
                  subtitle:
                      'Diskon ${hemat.last.discountPercentage.round()}% - '
                      '${hemat.first.discountPercentage.round()}%',
                  icon: Icons.savings_outlined,
                  products: hemat,
                ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            ],
          ),
        );
      },
    );
  }

  Widget _promoSection({
    required GlobalKey sectionKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Product> products,
  }) {
    return Column(
      key: sectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${products.length} produk',
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final p = products[index];
              return SizedBox(
                width: 160,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [Positioned.fill(child: ProductCard(product: p))],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildBudgetWidget() {
    return AnimatedBuilder(
      animation: BudgetRepository.instance,
      builder: (context, _) {
        final repo = BudgetRepository.instance;

        if (!repo.hasBudget) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.ink,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set Budget Belanja',
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Pantau pengeluaran bulananmu',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 11.5,
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
            ),
          );
        }

        final progress = repo.progress;
        final isOver = repo.isOverBudget;
        final isNear = repo.isNearLimit;
        final percent = (progress * 100).clamp(0, 999).toStringAsFixed(0);

        Color progressColor;
        if (isOver) {
          progressColor = AppColors.danger;
        } else if (isNear) {
          progressColor = const Color(0xFFE0A458);
        } else {
          progressColor = const Color(0xFF6BAE85);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Material(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BudgetScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'BUDGET BULAN INI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$percent%',
                          style: TextStyle(
                            color: progressColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Rp${_fmtShort(repo.totalSpent)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'dari Rp${_fmtShort(repo.budget!.limit)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(progressColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          isOver
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color: isOver
                              ? AppColors.danger
                              : Colors.white.withValues(alpha: 0.6),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOver
                              ? 'Over budget Rp${_fmtShort(repo.totalSpent - repo.budget!.limit)}'
                              : 'Sisa Rp${_fmtShort(repo.remaining)}',
                          style: TextStyle(
                            color: isOver
                                ? AppColors.danger
                                : Colors.white.withValues(alpha: 0.6),
                            fontSize: 11.5,
                            fontWeight: isOver
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    final now = DateTime.now();
    final sinceLast = _lastRefreshTime == null
        ? const Duration(days: 1)
        : now.difference(_lastRefreshTime!);

    final shouldShuffle = sinceLast.inSeconds >= 5;

    final newProducts = await ProductRepository.instance.all(refresh: true);

    final finalProducts = shouldShuffle
        ? (List<Product>.from(newProducts)..shuffle())
        : newProducts;

    _lastRefreshTime = now;

    if (!mounted) return;
    setState(() {
      _productsFuture = Future.value(finalProducts);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                shouldShuffle ? Icons.shuffle : Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  shouldShuffle
                      ? 'Menampilkan produk baru untukmu'
                      : 'Sudah yang terbaru',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
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
                  return GestureDetector(
                    onTap: () {
                      final targetSection =
                          banner['targetSection'] as int? ?? 0;
                      _openPromoSection(targetSection);
                    },
                    child: Container(
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
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      'Lihat promo',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ],
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
            const SizedBox(height: 24),
            _buildBudgetWidget(),
            const SizedBox(height: 24),
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
                      onTap: () => _openSearch(category: cat['slug']),
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

String _fmtShort(num value) {
  final str = value.toInt().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
  }
  return buffer.toString();
}
