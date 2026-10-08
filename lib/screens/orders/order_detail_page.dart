import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/order_store.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Nomor pesanan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nomor Pesanan',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  order.id,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tanggal: ${order.date.day}/${order.date.month}/${order.date.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Daftar produk
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),

                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          'x${item.qty}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Informasi pengiriman
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alamat Pengiriman',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  order.address,
                  style: const TextStyle(color: AppColors.ink),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Pembayaran dan total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pembayaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  order.payment,
                  style: const TextStyle(color: AppColors.ink),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pesanan',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Rp ${order.total}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tombol tracking
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Tracking akan disambungkan setelah ini
              },
              child: const Text('Lacak Pesanan'),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
