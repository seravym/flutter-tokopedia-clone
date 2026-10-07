import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/order_store.dart';

class TrackingOrderPage extends StatelessWidget {
  final Order order;

  const TrackingOrderPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Lacak Pesanan'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomor Pesanan',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.id,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total Rp ${order.total}',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Status Pesanan',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 18),

            _buildStatus(
              icon: Icons.receipt_long,
              title: 'Pesanan dibuat',
              subtitle: 'Pesanan berhasil dibuat',
              active: true,
              isLast: false,
            ),

            _buildStatus(
              icon: Icons.inventory_2_outlined,
              title: 'Pesanan diproses',
              subtitle: 'Pesanan sedang diproses oleh penjual',
              active: true,
              isLast: false,
            ),

            _buildStatus(
              icon: Icons.inventory_outlined,
              title: 'Pesanan dikemas',
              subtitle: 'Pesanan sedang dikemas',
              active: true,
              isLast: false,
            ),

            _buildStatus(
              icon: Icons.local_shipping_outlined,
              title: 'Pesanan dikirim',
              subtitle: 'Menunggu pesanan dikirim',
              active: false,
              isLast: false,
            ),

            _buildStatus(
              icon: Icons.check_circle_outline,
              title: 'Pesanan selesai',
              subtitle: 'Pesanan telah diterima',
              active: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool active,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: active ? Colors.white : AppColors.muted,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 55,
                color: active ? AppColors.accent : AppColors.border,
              ),
          ],
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: active ? AppColors.ink : AppColors.muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
