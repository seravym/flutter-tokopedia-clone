import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

import 'product_repository.dart';

class DetectedObject {
  final String label;
  final double confidence;

  final String? categorySlug;

  const DetectedObject({
    required this.label,
    required this.confidence,
    this.categorySlug,
  });
}

class ImageSearchService {
  ImageSearchService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pick(ImageSource source) {
    return _picker.pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 85,
    );
  }

  static Future<List<DetectedObject>> detect(String path) async {
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
    try {
      final labels = await labeler.processImage(InputImage.fromFilePath(path));
      labels.sort((a, b) => b.confidence.compareTo(a.confidence));

      final known = ProductRepository.instance.categories;
      final seen = <String>{};
      final result = <DetectedObject>[];

      for (final l in labels) {
        if (!seen.add(l.label.toLowerCase())) continue;
        var slug = _slugFor(l.label);
        if (slug != null && known.isNotEmpty && !known.contains(slug)) {
          slug = null;
        }
        result.add(DetectedObject(
          label: l.label,
          confidence: l.confidence,
          categorySlug: slug,
        ));
        if (result.length >= 6) break;
      }

      result.sort((a, b) {
        final am = a.categorySlug != null ? 0 : 1;
        final bm = b.categorySlug != null ? 0 : 1;
        if (am != bm) return am - bm;
        return b.confidence.compareTo(a.confidence);
      });
      return result;
    } finally {
      await labeler.close();
    }
  }

  static String? _slugFor(String label) {
    final l = label.toLowerCase();
    final exact = _labelToCategory[l];
    if (exact != null) return exact;
    for (final e in _labelToCategory.entries) {
      if (l.contains(e.key)) return e.value;
    }
    return null;
  }

  static const Map<String, String> _labelToCategory = {
    // Elektronik
    'mobile phone': 'smartphones',
    'smartphone': 'smartphones',
    'telephone': 'smartphones',
    'cellular': 'smartphones',
    'gadget': 'smartphones',
    'laptop': 'laptops',
    'netbook': 'laptops',
    'personal computer': 'laptops',
    'computer': 'laptops',
    'tablet': 'tablets',
    // Fashion
    'sneakers': 'mens-shoes',
    'shoe': 'mens-shoes',
    'footwear': 'mens-shoes',
    'boot': 'mens-shoes',
    'sandal': 'womens-shoes',
    'high heels': 'womens-shoes',
    'dress': 'womens-dresses',
    'gown': 'womens-dresses',
    'shirt': 'mens-shirts',
    't-shirt': 'tops',
    'blouse': 'tops',
    'top': 'tops',
    'handbag': 'womens-bags',
    'bag': 'womens-bags',
    'backpack': 'womens-bags',
    'purse': 'womens-bags',
    'jewellery': 'womens-jewellery',
    'jewelry': 'womens-jewellery',
    'necklace': 'womens-jewellery',
    'earrings': 'womens-jewellery',
    'ring': 'womens-jewellery',
    'bracelet': 'womens-jewellery',
    'watch': 'mens-watches',
    'wristwatch': 'mens-watches',
    'clock': 'mens-watches',
    'sunglasses': 'sunglasses',
    'glasses': 'sunglasses',
    'goggles': 'sunglasses',
    // Kecantikan
    'lipstick': 'beauty',
    'cosmetics': 'beauty',
    'makeup': 'beauty',
    'eye shadow': 'beauty',
    'mascara': 'beauty',
    'nail polish': 'beauty',
    'skin care': 'skin-care',
    'cream': 'skin-care',
    'perfume': 'fragrances',
    'fragrance': 'fragrances',
    // Rumah
    'chair': 'furniture',
    'table': 'furniture',
    'couch': 'furniture',
    'sofa': 'furniture',
    'furniture': 'furniture',
    'bed': 'furniture',
    'shelf': 'furniture',
    'lamp': 'home-decoration',
    'vase': 'home-decoration',
    'houseplant': 'home-decoration',
    'plant': 'home-decoration',
    'picture frame': 'home-decoration',
    'kitchen': 'kitchen-accessories',
    'cookware': 'kitchen-accessories',
    'pan': 'kitchen-accessories',
    'cutlery': 'kitchen-accessories',
    'spoon': 'kitchen-accessories',
    'fork': 'kitchen-accessories',
    'knife': 'kitchen-accessories',
    // Makanan
    'fruit': 'groceries',
    'vegetable': 'groceries',
    'food': 'groceries',
    'egg': 'groceries',
    'bread': 'groceries',
    // Olahraga & kendaraan
    'ball': 'sports-accessories',
    'racket': 'sports-accessories',
    'sports equipment': 'sports-accessories',
    'motorcycle': 'motorcycle',
    'scooter': 'motorcycle',
    'car': 'vehicle',
    'vehicle': 'vehicle',
    'truck': 'vehicle',
  };
}
