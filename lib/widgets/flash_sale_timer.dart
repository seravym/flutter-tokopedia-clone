import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';

class FlashSaleTimer extends StatefulWidget {
  final double discountPercentage;
  const FlashSaleTimer({super.key, required this.discountPercentage});

  @override
  State<FlashSaleTimer> createState() => _FlashSaleTimerState();
}

class _FlashSaleTimerState extends State<FlashSaleTimer> {
  static const int _blockHours = 3;
  Timer? _ticker;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final now = DateTime.now();
    final nextHour = (now.hour ~/ _blockHours + 1) * _blockHours;
    final end = DateTime(now.year, now.month, now.day, nextHour);
    if (!mounted) return;
    setState(() => _left = end.difference(now));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Widget _box(String v) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          v,
          style: T.s(13, w: FontWeight.w800, c: AppColors.peach),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final h = _left.inHours;
    final m = _left.inMinutes % 60;
    final s = _left.inSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B4A), Color(0xFFFF9A5A)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Flash Sale -${widget.discountPercentage.round()}%',
              style: T.s(14, w: FontWeight.w800, c: Colors.white),
            ),
          ),
          _box(_two(h)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Text(':',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          _box(_two(m)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Text(':',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          _box(_two(s)),
        ],
      ),
    );
  }
}
