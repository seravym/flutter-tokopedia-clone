import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final Color _bodyColor = Colors.grey[100]!;     
  final Color _appBarColor = Colors.white;        
  final Color _accentColor = Colors.black;        
  final Color _darkTextColor = Colors.black;
  final Color _greyTextColor = Colors.grey;

  final List<Map<String, String>> dummyProducts = List.generate(
    10,
    (index) => {
      'name': 'Produk Rekomendasi ${index + 1}',
      'price': 'Rp ${(index + 1) * 15000}',
      'imageUrl': 'https://picsum.photos/200/300?random=$index',
    },
  );

  final List<Map<String, dynamic>> categories = [
    {'name': 'Elektronik', 'icon': Icons.devices},
    {'name': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'Makanan', 'icon': Icons.fastfood},
    {'name': 'Kesehatan', 'icon': Icons.medical_services},
    {'name': 'Olahraga', 'icon': Icons.sports_soccer},
    {'name': 'Otomotif', 'icon': Icons.directions_car},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bodyColor,
      appBar: AppBar(
        backgroundColor: _appBarColor, 
        elevation: 1,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.search, color: _greyTextColor),
              const SizedBox(width: 8),
              Text(
                'Cari di Tokopedia',
                style: TextStyle(color: _greyTextColor, fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentIndex = 1;
              });
            },
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
          ),
        ],
      ),

      body: _buildBody(),

      bottomNavigationBar: Container(
        color: _accentColor, 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
            backgroundColor: _accentColor,
            color: Colors.grey,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            selectedIndex: _currentIndex,
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.shopping_cart, text: 'Cart'),
              GButton(icon: Icons.search, text: 'Search'),
              GButton(icon: Icons.settings, text: 'Settings'),
              GButton(icon: Icons.account_circle_rounded, text: 'Account'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return Center(child: Text('Halaman Keranjang', style: TextStyle(color: _darkTextColor)));
      case 2:
        return Center(child: Text('Halaman Pencarian', style: TextStyle(color: _darkTextColor)));
      case 3:
        return Center(child: Text('Halaman Pengaturan', style: TextStyle(color: _darkTextColor)));
      case 4:
        return Center(child: Text('Halaman Profil', style: TextStyle(color: _darkTextColor)));
      default:
        return _buildHomeContent();
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beranda berhasil di-refresh!'),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  Widget _buildHomeContent() {
    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      color: Colors.black,
      backgroundColor: Colors.white,
      showChildOpacityTransition: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _accentColor, 
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Banner Promo Spesial',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Kategori Pilihan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _darkTextColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kategori ${cat['name']} diklik')),
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[200], 
                            child: Icon(
                              cat['icon'],
                              color: _accentColor, 
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['name'],
                            style: TextStyle(fontSize: 12, color: _darkTextColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Rekomendasi Untukmu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _darkTextColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: dummyProducts.length,
              itemBuilder: (context, index) {
                final product = dummyProducts[index];
                return ProductCard(
                  name: product['name']!,
                  price: product['price']!,
                  imageUrl: product['imageUrl']!,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}