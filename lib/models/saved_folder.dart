import 'product.dart';

class SavedFolder {
  final String id;
  String name;
  final DateTime createdAt;
  final List<Product> products;

  SavedFolder({
    required this.id,
    required this.name,
    DateTime? createdAt,
    List<Product>? products,
  })  : createdAt = createdAt ?? DateTime.now(),
        products = products ?? [];

  int get count => products.length;

  factory SavedFolder.fromJson(Map<String, dynamic> j) => SavedFolder(
        id: j['id'] as String,
        name: j['name'] as String,
        createdAt: DateTime.tryParse((j['createdAt'] as String?) ?? ''),
        products: ((j['products'] as List?) ?? const [])
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'products': products.map((p) => p.toJson()).toList(),
      };
}
