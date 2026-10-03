const double kUsdToIdr = 16000;

const int kMaxQtyPerItem = 20;

int usdToIdr(num usd) => ((usd * kUsdToIdr) / 100).round() * 100;

String rupiahInt(int value) {
  final s = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${value < 0 ? '-' : ''}Rp$buf';
}

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String tanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

const _kategoriId = {
  'beauty': 'Kecantikan',
  'fragrances': 'Parfum',
  'furniture': 'Furnitur',
  'groceries': 'Sembako',
  'home-decoration': 'Dekorasi Rumah',
  'kitchen-accessories': 'Dapur',
  'laptops': 'Laptop',
  'mens-shirts': 'Kemeja Pria',
  'mens-shoes': 'Sepatu Pria',
  'mens-watches': 'Jam Pria',
  'mobile-accessories': 'Aksesoris HP',
  'motorcycle': 'Motor',
  'skin-care': 'Skincare',
  'smartphones': 'Smartphone',
  'sports-accessories': 'Olahraga',
  'sunglasses': 'Kacamata',
  'tablets': 'Tablet',
  'tops': 'Atasan',
  'vehicle': 'Kendaraan',
  'womens-bags': 'Tas Wanita',
  'womens-dresses': 'Dress',
  'womens-jewellery': 'Perhiasan',
  'womens-shoes': 'Sepatu Wanita',
  'womens-watches': 'Jam Wanita',
};

String kategoriLabel(String slug) {
  final v = _kategoriId[slug];
  if (v != null) return v;
  return slug
      .split('-')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
