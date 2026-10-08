import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../models/product.dart';
import '../../services/product_repository.dart';
import '../../services/app_nav.dart';
import '../../widgets/search/search_bar_widget.dart';
import '../../widgets/search/filter_chip_widget.dart';
import '../../widgets/search/advanced_filter_bottom_sheet.dart';
import '../../widgets/search/product_search_skeleton.dart';
import '../../widgets/common.dart';
import '../../widgets/product_card.dart';

enum SortOption { defaultSort, lowestPrice, highestPrice, topRating }

class SearchScreen extends StatefulWidget {
  final VoidCallback? onClose;
  const SearchScreen({super.key, this.onClose});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ProductRepository _repo = ProductRepository.instance;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  List<String> _searchHistory = [];

  String _searchQuery = '';
  String? _selectedCategory;
  SortOption _currentSort = SortOption.defaultSort;

  double? _minPrice;
  double? _maxPrice;
  bool _fastShippingOnly = false;
  int _minRating = 0;

  bool _isLoading = true;
  bool _isSearching = false;

  static const String _historyPrefKey = 'tokopedia_search_history';

  bool get _shouldShowHistory =>
      _isSearching &&
      _searchQuery.isEmpty &&
      _selectedCategory == null;

  @override
  void initState() {
    super.initState();
    _initData();

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus &&
            _searchQuery.isEmpty &&
            _selectedCategory == null;
      });
    });

    AppNav.searchIntent.addListener(_handleSearchIntent);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    AppNav.searchIntent.removeListener(_handleSearchIntent);
    super.dispose();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);

    await Future.wait([
      _loadProducts(),
      _loadSearchHistory(),
      Future.delayed(const Duration(milliseconds: 600)),
    ]);

    _handleSearchIntent();
    _applyFiltersAndSort();

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadProducts() async {
    _allProducts = await _repo.all();
    _categories = _repo.categories;
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyPrefKey);
    if (history != null) {
      _searchHistory = history;
    }
  }

  Future<void> _saveToHistory(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    _searchHistory.removeWhere(
      (item) => item.toLowerCase() == cleanQuery.toLowerCase(),
    );
    _searchHistory.insert(0, cleanQuery);

    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }

    await prefs.setStringList(_historyPrefKey, _searchHistory);
    if (mounted) setState(() {});
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyPrefKey);
    if (!mounted) return;
    setState(() => _searchHistory.clear());
  }

  void _handleSearchIntent() {
    final intent = AppNav.searchIntent.value;
    if (intent == null) return;

    if (intent.query != null) {
      _searchController.text = intent.query!;
      _searchQuery = intent.query!;
      _saveToHistory(_searchQuery);
    }

    if (intent.category != null) {
      _selectedCategory = intent.category;
      _isSearching = false;
    }

    if (intent.tag != null) {
      _searchController.text = intent.tag!;
      _searchQuery = intent.tag!;
    }

    _searchFocusNode.unfocus();
    _applyFiltersAndSort();
    AppNav.searchIntent.value = null;
  }

  void _executeSearch(String query) {
    _searchQuery = query;
    _searchFocusNode.unfocus();
    _saveToHistory(query);
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _applyFiltersAndSort();
      setState(() => _isLoading = false);
    });
  }

  void _applyFiltersAndSort() {
    final queryLower = _searchQuery.toLowerCase();

    final result = _allProducts.where((p) {
      final matchesQuery = queryLower.isEmpty ||
          p.title.toLowerCase().contains(queryLower) ||
          (p.brand?.toLowerCase().contains(queryLower) ?? false) ||
          p.tags.any((tag) => tag.toLowerCase().contains(queryLower));

      final matchesCategory =
          _selectedCategory == null || p.category == _selectedCategory;
      final matchesMinPrice = _minPrice == null || p.finalIdr >= _minPrice!;
      final matchesMaxPrice = _maxPrice == null || p.finalIdr <= _maxPrice!;
      final matchesShipping = !_fastShippingOnly || p.fastShipping;
      final matchesRating = p.rating >= _minRating;

      return matchesQuery &&
          matchesCategory &&
          matchesMinPrice &&
          matchesMaxPrice &&
          matchesShipping &&
          matchesRating;
    }).toList();

    switch (_currentSort) {
      case SortOption.lowestPrice:
        result.sort((a, b) => a.finalIdr.compareTo(b.finalIdr));
        break;
      case SortOption.highestPrice:
        result.sort((a, b) => b.finalIdr.compareTo(a.finalIdr));
        break;
      case SortOption.topRating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.defaultSort:
        break;
    }

    if (!mounted) return;
    setState(() {
      _filteredProducts = result;
      _isSearching = _searchFocusNode.hasFocus &&
          _searchQuery.isEmpty &&
          _selectedCategory == null;
    });
  }

  Future<void> _showAdvancedFilter() async {
    _searchFocusNode.unfocus();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => AdvancedFilterBottomSheet(
        currentMinPrice: _minPrice,
        currentMaxPrice: _maxPrice,
        currentFastShipping: _fastShippingOnly,
        currentMinRating: _minRating,
        currentSort: _currentSort,
      ),
    );

    if (result != null) {
      setState(() {
        _minPrice = result['minPrice'];
        _maxPrice = result['maxPrice'];
        _fastShippingOnly = result['fastShipping'];
        _minRating = result['minRating'];
        _currentSort = result['sortOption'];
      });
      _applyFiltersAndSort();
    }
  }

  Widget _buildSearchSuggestions() {
    if (_searchQuery.isEmpty) {
      return _buildSearchHistory();
    }

    final queryLower = _searchQuery.toLowerCase();
    final suggestions = <String>{};

    for (final p in _allProducts) {
      if (p.title.toLowerCase().contains(queryLower)) suggestions.add(p.title);
      if (p.brand != null && p.brand!.toLowerCase().contains(queryLower)) {
        suggestions.add(p.brand!);
      }
      for (final tag in p.tags) {
        if (tag.toLowerCase().contains(queryLower)) suggestions.add(tag);
      }
      if (suggestions.length >= 8) break;
    }

    if (suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text('Cari "$_searchQuery"...', style: T.body),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: suggestions
          .map(
            (s) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.search_rounded, color: AppColors.sub),
              title: Text(s, style: T.body),
              trailing: const Icon(
                Icons.north_west_rounded,
                size: 16,
                color: AppColors.sub,
              ),
              onTap: () {
                _searchController.text = s;
                _executeSearch(s);
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              const Icon(Icons.history_rounded, size: 60, color: AppColors.line),
              const SizedBox(height: 16),
              Text(
                "Belum ada riwayat pencarian",
                style: T.s(14, c: AppColors.sub),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Pencarian Terakhir", style: T.h3),
            TextButton(
              onPressed: _clearHistory,
              child: Text(
                "Hapus Semua",
                style: T.s(13, w: FontWeight.w700, c: AppColors.peach),
              ),
            ),
          ],
        ),
        ..._searchHistory.map(
          (query) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.history_rounded, color: AppColors.sub),
            title: Text(query, style: T.body),
            trailing: const Icon(
              Icons.north_west_rounded,
              size: 16,
              color: AppColors.sub,
            ),
            onTap: () {
              _searchController.text = query;
              _executeSearch(query);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // === Search bar header ===
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarWidget(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSubmitted: _executeSearch,
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      if (val.isNotEmpty) _applyFiltersAndSort();
                    },
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      _searchFocusNode.requestFocus();
                      _applyFiltersAndSort();
                    },
                    onBack: widget.onClose,
                  ),
                  if (_isSearching && _searchQuery.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'Kemeja Pria',
                            'Sepatu Wanita',
                            'Laptop',
                            'Skincare',
                          ]
                              .map(
                                (tag) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ActionChip(
                                    label: Text(
                                      tag,
                                      style: T.s(12, c: AppColors.sub),
                                    ),
                                    backgroundColor: AppColors.bg,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    onPressed: () {
                                      _searchController.text = tag;
                                      _executeSearch(tag);
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // === Body ===
            Expanded(
              child: _isSearching
                  ? _buildSearchSuggestions()
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor: Colors.white,
                          automaticallyImplyLeading: false,
                          pinned: true,
                          elevation: 1,
                          shadowColor: Colors.black.withValues(alpha: 0.1),
                          toolbarHeight: 65,
                          flexibleSpace: FlexibleSpaceBar(
                            background: _buildFilterPanel(),
                          ),
                        ),

                        if (!_isLoading)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Menampilkan ${_filteredProducts.length} produk",
                                    style: T.s(
                                      13,
                                      c: AppColors.sub,
                                      w: FontWeight.w600,
                                    ),
                                  ),
                                  if (_currentSort != SortOption.defaultSort)
                                    Text(
                                      "Diurutkan",
                                      style: T.s(
                                        12,
                                        c: AppColors.green,
                                        w: FontWeight.w700,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                        if (_isLoading)
                          const ProductSearchSkeleton()
                        else if (_filteredProducts.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: EmptyState(
                                icon: Icons.search_off_rounded,
                                title: 'Oops, produk tidak ditemukan',
                                subtitle:
                                    'Coba kurangi filter atau gunakan kata kunci yang lebih umum.',
                                actionLabel: 'Hapus Semua Filter',
                                onAction: _resetFilters,
                              ),
                            ),
                          )
                        else
                          ProductSearchGrid(products: _filteredProducts),

                        const SliverToBoxAdapter(
                          child: SizedBox(height: 100),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = null;
      _minPrice = null;
      _maxPrice = null;
      _fastShippingOnly = false;
      _minRating = 0;
      _currentSort = SortOption.defaultSort;
    });
    _applyFiltersAndSort();
  }

  Widget _buildFilterPanel() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Tombol filter lanjutan
          Builder(
            builder: (context) {
              final isActive = _minPrice != null ||
                  _maxPrice != null ||
                  _fastShippingOnly ||
                  _minRating > 0 ||
                  _currentSort != SortOption.defaultSort;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: _showAdvancedFilter,
                  icon: Icon(
                    Icons.tune_rounded,
                    color: isActive ? Colors.white : AppColors.ink,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        isActive ? AppColors.green : AppColors.bg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isActive ? AppColors.green : AppColors.line,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Chip "Semua"
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChipWidget(
              label: "Semua",
              isSelected: _selectedCategory == null,
              onTap: () {
                setState(() => _selectedCategory = null);
                _applyFiltersAndSort();
              },
            ),
          ),

          // Chip kategori
          ..._categories.map((cat) {
            final formattedCat = cat
                .split('-')
                .map(
                  (w) => w.isNotEmpty
                      ? w[0].toUpperCase() + w.substring(1)
                      : w,
                )
                .join(' ');

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChipWidget(
                label: formattedCat,
                isSelected: _selectedCategory == cat,
                onTap: () {
                  setState(() {
                    _selectedCategory =
                        _selectedCategory == cat ? null : cat;
                  });
                  _applyFiltersAndSort();
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}