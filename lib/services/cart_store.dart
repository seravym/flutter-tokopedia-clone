import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/format.dart';
import '../models/product.dart';

class CartItem {
  final int id;
  final String title;
  final String thumbnail;
  final String brand;
  final int priceIdr;
  final int originalIdr;
  final int stock;
  int qty;
  bool selected;

  CartItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.brand,
    required this.priceIdr,
    required this.originalIdr,
    required this.stock,
    required this.qty,
    this.selected = true,
  });

  int get maxQty => stock < kMaxQtyPerItem ? stock : kMaxQtyPerItem;

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        id: j['id'] as int,
        title: j['title'] as String,
        thumbnail: j['thumbnail'] as String,
        brand: j['brand'] as String,
        priceIdr: j['priceIdr'] as int,
        originalIdr: j['originalIdr'] as int,
        stock: j['stock'] as int,
        qty: j['qty'] as int,
        selected: j['selected'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnail': thumbnail,
        'brand': brand,
        'priceIdr': priceIdr,
        'originalIdr': originalIdr,
        'stock': stock,
        'qty': qty,
        'selected': selected,
      };
}

enum AddResult { added, reachedLimit, outOfStock }

class CartStore extends ChangeNotifier {
  CartStore._();
  static final CartStore instance = CartStore._();

  static const _key = 'cart_v1';
  final List<CartItem> items = [];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      items
        ..clear()
        ..addAll(list.map((e) => CartItem.fromJson(e as Map<String, dynamic>)));
    } catch (_) {
      items.clear();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  int get totalQty => items.fold(0, (a, b) => a + b.qty);

  List<CartItem> get selectedItems => items.where((e) => e.selected).toList();
  int get selectedQty => selectedItems.fold(0, (a, b) => a + b.qty);
  int get subtotal =>
      selectedItems.fold(0, (a, b) => a + b.priceIdr * b.qty);
  int get savings => selectedItems.fold(
      0, (a, b) => a + (b.originalIdr - b.priceIdr) * b.qty);
  bool get allSelected => items.isNotEmpty && items.every((e) => e.selected);

  int qtyOf(int productId) {
    for (final i in items) {
      if (i.id == productId) return i.qty;
    }
    return 0;
  }

  AddResult add(Product p, {int qty = 1, bool exclusive = false}) {
    if (!p.inStock) return AddResult.outOfStock;
    var result = AddResult.added;
    final idx = items.indexWhere((e) => e.id == p.id);
    if (idx >= 0) {
      final it = items[idx];
      final target = it.qty + qty;
      if (target > it.maxQty) {
        it.qty = it.maxQty;
        result = AddResult.reachedLimit;
      } else {
        it.qty = target;
      }
    } else {
      final q = qty > p.maxQty ? p.maxQty : qty;
      if (qty > p.maxQty) result = AddResult.reachedLimit;
      items.insert(
        0,
        CartItem(
          id: p.id,
          title: p.title,
          thumbnail: p.thumbnail,
          brand: p.displayBrand,
          priceIdr: p.finalIdr,
          originalIdr: p.originalIdr,
          stock: p.stock,
          qty: q,
        ),
      );
    }
    if (exclusive) {
      for (final e in items) {
        e.selected = e.id == p.id;
      }
    } else {
      items.firstWhere((e) => e.id == p.id).selected = true;
    }
    _changed();
    return result;
  }

  bool setQty(CartItem item, int qty) {
    var ok = true;
    if (qty > item.maxQty) {
      qty = item.maxQty;
      ok = false;
    }
    if (qty < 1) qty = 1;
    item.qty = qty;
    _changed();
    return ok;
  }

  void toggle(CartItem item, bool value) {
    item.selected = value;
    _changed();
  }

  void selectAll(bool value) {
    for (final e in items) {
      e.selected = value;
    }
    _changed();
  }

  void remove(CartItem item) {
    items.remove(item);
    _changed();
  }

  void restore(CartItem item, int index) {
    items.insert(index.clamp(0, items.length).toInt(), item);
    _changed();
  }

  void removeSelected() {
    items.removeWhere((e) => e.selected);
    _changed();
  }
}
