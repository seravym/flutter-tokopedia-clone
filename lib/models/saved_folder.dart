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
}