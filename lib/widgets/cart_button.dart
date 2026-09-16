import 'package:flutter/material.dart';

import '../cart_page.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
      },
      icon: const Icon(Icons.shopping_cart),
    );
  }
}
