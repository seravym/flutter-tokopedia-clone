import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductRepository {
  ProductRepository._();
  static final ProductRepository instance = ProductRepository._();

  static const _url = 'https://dummyjson.com/products?limit=0';

  List<Product>? _cache;
  Future<List<Product>>? _inflight;

  List<Product>? get cached => _cache;

  Future<List<Product>> all({bool refresh = false}) {
    if (!refresh && _cache != null) return Future.value(_cache!);
    return _inflight ??= _load().whenComplete(() => _inflight = null);
  }

  Future<List<Product>> _load() async {
    final res = await http
        .get(Uri.parse(_url))
        .timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Server error ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['products'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache = list;
    return list;
  }

  Product? byId(int id) {
    final c = _cache;
    if (c == null) return null;
    for (final p in c) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<String> get categories {
    final c = _cache ?? const <Product>[];
    final set = <String>{};
    for (final p in c) {
      set.add(p.category);
    }
    final l = set.toList()..sort();
    return l;
  }

  List<String> popularTags({int limit = 12}) {
    final c = _cache ?? const <Product>[];
    final count = <String, int>{};
    for (final p in c) {
      for (final t in p.tags) {
        count[t] = (count[t] ?? 0) + 1;
      }
    }
    final keys = count.keys.toList()
      ..sort((a, b) => count[b]!.compareTo(count[a]!));
    return keys.take(limit).toList();
  }

  List<Product> siblings(Product p) {
    if (p.brand == null) return const [];
    return (_cache ?? const <Product>[])
        .where((o) =>
            o.id != p.id && o.brand == p.brand && o.category == p.category)
        .toList();
  }

  List<Product> related(Product p, {int limit = 10}) {
    return (_cache ?? const <Product>[])
        .where((o) => o.id != p.id && o.category == p.category)
        .take(limit)
        .toList();
  }
}
