import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _ink = Color(0xFF0A0A0A);
  static const _sub = Color(0xFF737373);
  static const _line = Color(0xFFEAEAEA);
  static const _chip = Color(0xFFF4F4F4);

  static const _kOrder = 'settings_notif_order';
  static const _kPromo = 'settings_notif_promo';
  static const _kLang = 'settings_language';

  bool _orderNotif = true;
  bool _promoNotif = true;
  String _language = 'Bahasa Indonesia';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _orderNotif = p.getBool(_kOrder) ?? true;
        _promoNotif = p.getBool(_kPromo) ?? true;
        _language = p.getString(_kLang) ?? 'Bahasa Indonesia';
      });
    } catch (_) {
    }
  }

  Future<void> _saveBool(String key, bool value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(key, value);
    } catch (_) {}
  }

  Future<void> _saveString(String key, String value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(key, value);
    } catch (_) {}
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _pickLanguage() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih bahasa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final l in const ['Bahasa Indonesia', 'English'])
                InkWell(
                  onTap: () {
                    setState(() => _language = l);
                    _saveString(_kLang, l);
                    Navigator.pop(ctx);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (l == _language)
                          const Icon(Icons.check_rounded, color: _ink),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearImageCache() {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    _snack('Cache gambar dibersihkan');
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pusat Bantuan'),
        content: const Text(
          'Ada kendala saat berbelanja? Tim kami siap membantu '
          'setiap hari pukul 08.00 - 21.00 WIB.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Tokopedia Clone',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Tugas Mobile Programming',
    );
  }

  Widget _header() {
    final user = AuthStore.instance.user;
    final name = (user?.name ?? '').trim().isEmpty ? 'Tamu' : user!.name;
    final email = user?.email ?? 'Belum masuk';
    final initial = name.trim()[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0A0A), Color(0xFF2B2B2B)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String label, List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(const Divider(height: 1, indent: 70, color: _line));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: _sub,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _line),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _chip,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: _ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          style: const TextStyle(fontSize: 12.5, color: _sub),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _switch(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? _ink
            : const Color(0xFFD4D4D4),
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  Widget _chevron() =>
      const Icon(Icons.chevron_right_rounded, color: _sub, size: 22);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _FadeSlide(order: 0, child: _header()),
        const SizedBox(height: 24),
        _FadeSlide(
          order: 1,
          child: _section('NOTIFIKASI', [
            _row(
              icon: Icons.local_shipping_outlined,
              title: 'Notifikasi pesanan',
              subtitle: 'Status pembayaran & pengiriman',
              trailing: _switch(_orderNotif, (v) {
                setState(() => _orderNotif = v);
                _saveBool(_kOrder, v);
              }),
              onTap: () {
                setState(() => _orderNotif = !_orderNotif);
                _saveBool(_kOrder, _orderNotif);
              },
            ),
            _row(
              icon: Icons.local_offer_outlined,
              title: 'Promo & penawaran',
              subtitle: 'Flash sale dan voucher terbaru',
              trailing: _switch(_promoNotif, (v) {
                setState(() => _promoNotif = v);
                _saveBool(_kPromo, v);
              }),
              onTap: () {
                setState(() => _promoNotif = !_promoNotif);
                _saveBool(_kPromo, _promoNotif);
              },
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _FadeSlide(
          order: 2,
          child: _section('PREFERENSI', [
            _row(
              icon: Icons.language_rounded,
              title: 'Bahasa',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _language,
                    style: const TextStyle(fontSize: 13, color: _sub),
                  ),
                  const SizedBox(width: 4),
                  _chevron(),
                ],
              ),
              onTap: _pickLanguage,
            ),
            _row(
              icon: Icons.cleaning_services_outlined,
              title: 'Bersihkan cache gambar',
              subtitle: 'Kosongkan gambar yang tersimpan sementara',
              trailing: _chevron(),
              onTap: _clearImageCache,
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _FadeSlide(
          order: 3,
          child: _section('LAINNYA', [
            _row(
              icon: Icons.help_outline_rounded,
              title: 'Pusat bantuan',
              trailing: _chevron(),
              onTap: _showHelp,
            ),
            _row(
              icon: Icons.info_outline_rounded,
              title: 'Tentang aplikasi',
              trailing: const Text(
                'v1.0.0',
                style: TextStyle(fontSize: 13, color: _sub),
              ),
              onTap: _showAbout,
            ),
          ]),
        ),
      ],
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final int order;
  final Widget child;
  const _FadeSlide({required this.order, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + order * 120),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}