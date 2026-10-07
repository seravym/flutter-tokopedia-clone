import 'package:flutter/material.dart';

import '../../services/order_store.dart';
import '../../core/theme.dart';
import 'tracking_order_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    OrderStore.instance.load().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = OrderStore.instance.orders;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text('Belum ada pesanan', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${order.date.day}/${order.date.month}/${order.date.year}',
                        ),
                        const SizedBox(height: 12),

                        ...order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Image.network(
                                  item.thumbnail,
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                      size: 55,
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${item.title}\nx${item.qty}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Divider(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pesanan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rp ${order.total}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TrackingOrderPage(order: order),
                                ),
                              );
                            },
                            child: const Text('Lacak Pesanan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
