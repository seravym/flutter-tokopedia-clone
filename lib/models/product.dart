import '../core/format.dart';

class Review {
  final int rating;
  final String comment;
  final DateTime? date;
  final String reviewerName;

  const Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
  });

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        rating: (j['rating'] as num?)?.toInt() ?? 0,
        comment: (j['comment'] as String?) ?? '',
        date: DateTime.tryParse((j['date'] as String?) ?? ''),
        reviewerName: (j['reviewerName'] as String?) ?? 'Pembeli',
      );
}

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double priceUsd;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String? brand;
  final String sku;
  final String warranty;
  final String shipping;
  final String availability;
  final String returnPolicy;
  final int minOrder;
  final String thumbnail;
  final List<String> images;
  final List<Review> reviews;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priceUsd,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.warranty,
    required this.shipping,
    required this.availability,
    required this.returnPolicy,
    required this.minOrder,
    required this.thumbnail,
    required this.images,
    required this.reviews,
  });

  factory Product.fromJson(Map<String, dynamic> j) {
    final thumb = (j['thumbnail'] as String?) ?? '';
    final imgs = ((j['images'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();
    if (imgs.isEmpty && thumb.isNotEmpty) imgs.add(thumb);
    return Product(
      id: (j['id'] as num).toInt(),
      title: (j['title'] as String?) ?? '',
      description: (j['description'] as String?) ?? '',
      category: (j['category'] as String?) ?? '',
      priceUsd: (j['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (j['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (j['rating'] as num?)?.toDouble() ?? 0,
      stock: (j['stock'] as num?)?.toInt() ?? 0,
      tags: ((j['tags'] as List?) ?? const []).map((e) => e.toString()).toList(),
      brand: j['brand'] as String?,
      sku: (j['sku'] as String?) ?? '-',
      warranty: (j['warrantyInformation'] as String?) ?? '-',
      shipping: (j['shippingInformation'] as String?) ?? '-',
      availability: (j['availabilityStatus'] as String?) ?? '-',
      returnPolicy: (j['returnPolicy'] as String?) ?? '-',
      minOrder: (j['minimumOrderQuantity'] as num?)?.toInt() ?? 1,
      thumbnail: thumb,
      images: imgs,
      reviews: ((j['reviews'] as List?) ?? const [])
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get originalIdr => usdToIdr(priceUsd);

  int get finalIdr => usdToIdr(priceUsd * (1 - discountPercentage / 100));

  bool get hasDiscount => discountPercentage >= 1 && originalIdr > finalIdr;

  bool get inStock => stock > 0;

  int get maxQty => stock < kMaxQtyPerItem ? stock : kMaxQtyPerItem;

  bool get fastShipping {
    final s = shipping.toLowerCase();
    return s.contains('overnight') || s.contains('1 day');
  }

  String get displayBrand => brand ?? kategoriLabel(category);
}
