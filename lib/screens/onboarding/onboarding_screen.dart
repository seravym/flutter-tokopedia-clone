import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController controller = PageController();
  int halaman = 0;

  void nextPage() {
    if (halaman < 2) {
      controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              onPageChanged: (index) {
                setState(() {
                  halaman = index;
                });
              },
              children: [
                // Halaman 1
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      size: 100,
                      color: Colors.green,
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Belanja Jadi Lebih Mudah',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'membantu belanja berbagai kebutuhan dengan mudah.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Halaman 2
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store,
                      size: 100,
                      color: Colors.green,
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Banyak Pilihan Produk',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Ayo temukan berbagai macam produk dari banyak toko.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Halaman 3
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 100,
                      color: Colors.green,
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Belanja dengan santai dan nyaman',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Nikmati pengalaman belanja yang aman dan nyaman.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              indicator(0),
              indicator(1),
              indicator(2),
            ],
          ),

          SizedBox(height: 25),

          // Tombol
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  halaman == 2 ? 'Mulai' : 'Lanjut',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget indicator(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: halaman == index ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: halaman == index
            ? Colors.green
            : Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}