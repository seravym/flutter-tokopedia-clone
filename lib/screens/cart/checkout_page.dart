import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../services/app_nav.dart';
import '../../services/auth_store.dart';
import '../../services/cart_store.dart';
import '../../services/order_store.dart';
import '../../widgets/common.dart';

const _payments = [
  ['Transfer Bank', 'BCA, Mandiri, BNI, BRI', 'account_balance'],
  ['E-Wallet', 'GoPay, OVO, DANA, ShopeePay', 'wallet'],
  ['Bayar di Tempat (COD)', 'Bayar tunai saat barang tiba', 'payments'],
];

IconData _payIcon(String k) {
  switch (k) {
    case 'account_balance':
      return Icons.account_balance_rounded;
    case 'wallet':
      return Icons.account_balance_wallet_rounded;
    default:
      return Icons.payments_rounded;
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _pay = 0;
  bool _busy = false;

  Future<void> _editAddress() async {
    final u = AuthStore.instance.user;
    if (u == null) return;
    final c = TextEditingController(text: u.address);
    final res = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alamat pengiriman', style: T.h2),
            const SizedBox(height: 14),
            TextField(
              controller: c,
              autofocus: true,
              maxLines: 3,
              style: T.body,
              decoration: InputDecoration(
                hintText: 'Jalan, nomor rumah, kelurahan, kota, kode pos',
                hintStyle: T.s(14, c: AppColors.sub),
                filled: true,
                fillColor: AppColors.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Simpan alamat',
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
            ),
          ],
        ),
      ),
    );
    if (res != null && res.isNotEmpty) {
      await AuthStore.instance.updateProfile(address: res);
      if (mounted) setState(() {});
    }
  }

  Future<void> _placeOrder() async {
    final user = AuthStore.instance.user;
    final cart = CartStore.instance;
    if (user == null || user.address.trim().isEmpty) {
      toast(context, 'Isi alamat pengiriman dulu ya',
          icon: Icons.location_off_outlined);
      _editAddress();
      return;
    }
    setState(() => _busy = true);
    final items = cart.selectedItems;
    final order = await OrderStore.instance.place(
      items: items,
      total: cart.subtotal,
      payment: _payments[_pay][0],
      address: user.address,
    );
    cart.removeSelected();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderSuccessPage(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartStore.instance;
    final user = AuthStore.instance.user;
    final items = cart.selectedItems;
    final hasAddress = user != null && user.address.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text('Checkout', style: T.h2),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _block(
            title: 'Alamat pengiriman',
            trailing: TextButton(
              onPressed: _editAddress,
              child: Text(hasAddress ? 'Ubah' : 'Isi',
                  style: T.s(13, w: FontWeight.w800, c: AppColors.green)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: AppColors.mint, shape: BoxShape.circle),
                  child: const Icon(Icons.location_on_rounded,
                      color: AppColors.green, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user?.name ?? '-'} • ${user?.phone ?? '-'}',
                          style: T.s(14, w: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        hasAddress
                            ? user.address
                            : 'Belum ada alamat. Tambahkan dulu ya.',
                        style: T.s(13,
                            c: hasAddress ? AppColors.ink : AppColors.peach,
                            h: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _block(
            title: 'Barang (${cart.selectedQty})',
            child: Column(
              children: [
                for (final it in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 56,
                            height: 56,
                            color: AppColors.mintSoft,
                            child: NetImage(it.thumbnail),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: T.s(13, w: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('${it.qty} x ${rupiahInt(it.priceIdr)}',
                                  style: T.small),
                            ],
                          ),
                        ),
                        Text(rupiahInt(it.priceIdr * it.qty),
                            style: T.s(13, w: FontWeight.w800)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _block(
            title: 'Metode pembayaran',
            child: Column(
              children: [
                for (var i = 0; i < _payments.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _pay = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _pay == i ? AppColors.mintSoft : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _pay == i ? AppColors.green : AppColors.line,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_payIcon(_payments[i][2]),
                              color: _pay == i
                                  ? AppColors.green
                                  : AppColors.sub),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_payments[i][0],
                                    style: T.s(14, w: FontWeight.w700)),
                                Text(_payments[i][1], style: T.small),
                              ],
                            ),
                          ),
                          Icon(
                            _pay == i
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: _pay == i
                                ? AppColors.green
                                : const Color(0xFFC6D1CB),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _block(
            title: 'Ringkasan belanja',
            child: Column(
              children: [
                _row('Total harga (${cart.selectedQty} barang)',
                    rupiahInt(cart.subtotal + cart.savings)),
                if (cart.savings > 0)
                  _row('Total diskon', '-${rupiahInt(cart.savings)}',
                      valueColor: AppColors.green),
                const Divider(height: 24, color: AppColors.line),
                _row('Total bayar', rupiahInt(cart.subtotal), bold: true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total bayar', style: T.small),
                  Text(rupiahInt(cart.subtotal),
                      style: T.s(20, w: FontWeight.w800, ls: -0.6)),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: PrimaryButton(
                label: _busy ? 'Memproses…' : 'Bayar',
                onPressed: (_busy || items.isEmpty) ? null : _placeOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v, {bool bold = false, Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(l,
                  style: bold
                      ? T.s(15, w: FontWeight.w800)
                      : T.s(13, c: AppColors.sub)),
            ),
            Text(v,
                style: T.s(bold ? 16 : 13,
                    w: bold ? FontWeight.w800 : FontWeight.w700,
                    c: valueColor ?? AppColors.ink)),
          ],
        ),
      );

  Widget _block({required String title, required Widget child, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow(0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: T.h3)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class OrderSuccessPage extends StatefulWidget {
  final Order order;
  const OrderSuccessPage({super.key, required this.order});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 72),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Pesanan berhasil! 🎉', style: T.h1),
                const SizedBox(height: 8),
                Text(
                  'Terima kasih sudah belanja.\nPesananmu segera diproses.',
                  textAlign: TextAlign.center,
                  style: T.s(14, c: AppColors.sub, h: 1.5),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _kv('No. pesanan', o.id),
                      _kv('Pembayaran', o.payment),
                      _kv('Total', rupiahInt(o.total), bold: true),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Kembali ke beranda',
                  onPressed: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    AppNav.tab.value = 0;
                  },
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Lihat pesanan saya',
                  outlined: true,
                  onPressed: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    AppNav.tab.value = 3;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(k, style: T.small)),
            Text(v, style: T.s(14, w: bold ? FontWeight.w800 : FontWeight.w700)),
          ],
        ),
      );
}
