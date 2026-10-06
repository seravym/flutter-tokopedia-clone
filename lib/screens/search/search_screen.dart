import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../models/product.dart';
import '../../services/product_repository.dart';
import '../../services/app_nav.dart';
import '../../widgets/search/search_bar_widget.dart';
import '../../widgets/search/filter_chip_widget.dart';
import '../../widgets/search/product_search_grid.dart';
import '../../widgets/search/advanced_filter_bottom_sheet.dart';
import '../../widgets/common.dart'; 


enum SortOption { defaultSort, lowestPrice, highestPrice, topRating }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _initData();
    
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus && _searchQuery.isEmpty;
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
    ]);
    
    _handleSearchIntent();
    _applyFiltersAndSort();
    
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

    _searchHistory.removeWhere((item) => item.toLowerCase() == cleanQuery.toLowerCase());
    _searchHistory.insert(0, cleanQuery);

    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    
    await prefs.setStringList(_historyPrefKey, _searchHistory);
    setState(() {});
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyPrefKey);
    setState(() {
      _searchHistory.clear();
    });
  }

  void _handleSearchIntent() {
    final intent = AppNav.searchIntent.value;
    if (intent != null) {
      if (intent.query != null) {
        _searchController.text = intent.query!;
        _searchQuery = intent.query!;
        _saveToHistory(_searchQuery);
      }
      if (intent.category != null) {
        _selectedCategory = intent.category;
      }
      if (intent.tag != null) {
        _searchController.text = intent.tag!;
        _searchQuery = intent.tag!;
      }
      _searchFocusNode.unfocus();
      _applyFiltersAndSort();
    }
  }

  void _executeSearch(String query) {
    _searchQuery = query;
    _searchFocusNode.unfocus();
    _saveToHistory(query);
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
  
    var result = _allProducts.where((p) {
      final queryLower = _searchQuery.toLowerCase();
      final matchesQuery = p.title.toLowerCase().contains(queryLower) || 
                           (p.brand?.toLowerCase().contains(queryLower) ?? false) ||
                           p.tags.any((tag) => tag.toLowerCase().contains(queryLower));
                           
      final matchesCategory = _selectedCategory == null || p.category == _selectedCategory;
      final matchesMinPrice = _minPrice == null || p.finalIdr >= _minPrice!;
      final matchesMaxPrice = _maxPrice == null || p.finalIdr <= _maxPrice!;
      final matchesShipping = !_fastShippingOnly || p.fastShipping;
      final matchesRating = p.rating >= _minRating;
      
      return matchesQuery && matchesCategory && matchesMinPrice && matchesMaxPrice && matchesShipping && matchesRating;
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
      default:

        break;
    }

    setState(() {
      _filteredProducts = result;
      _isSearching = _searchFocusNode.hasFocus && _searchQuery.isEmpty;
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

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 60, color: AppColors.line),
              const SizedBox(height: 16),
              Text("Belum ada riwayat pencarian", style: T.s(14, c: AppColors.sub)),
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
              child: Text("Hapus Semua", style: T.s(13, w: FontWeight.w700, c: AppColors.peach)),
            ),
          ],
        ),
        ..._searchHistory.map((query) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history_rounded, color: AppColors.sub),
          title: Text(query, style: T.body),
          trailing: const Icon(Icons.north_west_rounded, size: 16, color: AppColors.sub),
          onTap: () {
            _searchController.text = query;
            _executeSearch(query);
          },
        )),
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
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SearchBarWidget(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onSubmitted: _executeSearch,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _isSearching = val.isEmpty && _searchFocusNode.hasFocus;
                  });
                  if (val.isNotEmpty) _applyFiltersAndSort();
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _isSearching = true;
                  });
                  _applyFiltersAndSort();
                },
              ),
            ),
            
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                : _isSearching
                  ? _buildSearchHistory()
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
                        
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Menampilkan ${_filteredProducts.length} produk",
                                  style: T.s(13, c: AppColors.sub, w: FontWeight.w600),
                                ),
                                if (_currentSort != SortOption.defaultSort)
                                  Text(
                                    "Diurutkan",
                                    style: T.s(12, c: AppColors.green, w: FontWeight.w700),
                                  )
                              ],
                            ),
                          ),
                        ),

                        SliverPadding(
                          padding: const EdgeInsets.only(bottom: 100),
                          sliver: _filteredProducts.isEmpty
                            ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 60),
                                  child: EmptyState(
                                    icon: Icons.search_off_rounded,
                                    title: 'Oops, produk tidak ditemukan',
                                    subtitle: 'Coba kurangi filter atau gunakan kata kunci yang lebih umum.',
                                    actionLabel: 'Hapus Semua Filter',
                                    onAction: () {
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
                                    },
                                  ),
                                ),
                              )
                            : ProductSearchGrid(products: _filteredProducts),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isActive = _minPrice != null || _maxPrice != null || _fastShippingOnly || _minRating > 0 || _currentSort != SortOption.defaultSort;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: _showAdvancedFilter,
                icon: Icon(Icons.tune_rounded, color: isActive ? Colors.white : AppColors.ink, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: isActive ? AppColors.green : AppColors.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isActive ? AppColors.green : AppColors.line),
                  ),
                ),
              ),
            );
          }
          if (index == 1) {
            return FilterChipWidget(
              label: "Semua",
              isSelected: _selectedCategory == null,
              onTap: () {
                _selectedCategory = null;
                _applyFiltersAndSort();
              },
            );
          }
          final cat = _categories[index - 2];
          final formattedCat = cat.split('-').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w).join(' ');
          return FilterChipWidget(
            label: formattedCat,
            isSelected: _selectedCategory == cat,
            onTap: () {
              _selectedCategory = cat;
              _applyFiltersAndSort();
            },
          );
        },
      ),
    );
  }
}