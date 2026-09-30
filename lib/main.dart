import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'services/auth_store.dart';
import 'services/cart_store.dart';
import 'services/order_store.dart';
import 'services/product_repository.dart';
import 'screens/product/product_detail_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    AuthStore.instance.load(),
    CartStore.instance.load(),
    OrderStore.instance.load(),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        // SEMENTARA buat testing : fetch 1 produk dari API,
        // terus langsung tampilin ProductDetailPage punya Yona.
        // Nanti kalau SplashScreen punya Sabrina udah jadi, baris
        // "home:" ini WAJIB dibalikin lagi ke: const SplashScreen()
        home: FutureBuilder(
          future: ProductRepository.instance.all(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Gagal fetch: ${snapshot.error}')),
              );
            }
            final products = snapshot.data!;
            return ProductDetailPage(product: products.first);
          },
        ),
      );
}