import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import 'product_repository.dart';

class WishlistStore extends ChangeNotifier {
  WishlistStore._();
  static final WishlistStore instance = WishlistStore._();

  static const _key = 'wishlist_v1';
  final Set<int> _itemIds = {};


  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key);
      if (raw == null) return;
      _itemIds.clear();
      // Mengubah List<String> kembali menjadi int
      _itemIds.addAll(raw.map((e) => int.parse(e)));
    } catch (_) {
      _itemIds.clear();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _itemIds.map((e) => e.toString()).toList());
  }

  bool isFavorite(int productId) => _itemIds.contains(productId);

  void toggle(int productId) {
    if (_itemIds.contains(productId)) {
      _itemIds.remove(productId);
    } else {
      _itemIds.add(productId);
    }
    notifyListeners();
    _save();
  }

  void clearAll() {
    _itemIds.clear();
    notifyListeners();
    _save();
  }


  List<Product> get items {
    final repo = ProductRepository.instance;
    final list = <Product>[];
    for (final id in _itemIds) {
      final p = repo.byId(id);
      if (p != null) list.add(p);
    }
    return list;
  }
  
  int get count => _itemIds.length;
}