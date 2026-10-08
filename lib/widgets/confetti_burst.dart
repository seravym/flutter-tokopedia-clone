import 'dart:math' as math;

import 'package:flutter/material.dart';

class ConfettiBurst extends StatefulWidget {
  final VoidCallback? onDone;
  const ConfettiBurst({super.key, this.onDone});

  static void show(BuildContext context) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => ConfettiBurst(onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const _seconds = 2.4;

  late final AnimationController _c;
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    const colors = [
      Color(0xFF00A650),
      Color(0xFFFFB020),
      Color(0xFFFF6B4A),
      Color(0xFF7C5CFF),
      Color(0xFF0A0A0A),
    ];
    _pieces = List.generate(70, (_) {
      return _Piece(
        angle: -math.pi / 2 + (r.nextDouble() - 0.5) * math.pi * 1.1,
        speed: 260 + r.nextDouble() * 420,
        size: 6 + r.nextDouble() * 6,
        spin: (r.nextDouble() - 0.5) * 14,
        color: colors[r.nextInt(colors.length)],
      );
    });

    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_seconds * 1000).round()),
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone?.call();
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => SizedBox.expand(
          child: CustomPaint(
            painter: _ConfettiPainter(_c.value, _seconds, _pieces),
          ),
        ),
      ),
    );
  }
}

class _Piece {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;
  const _Piece({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  final double totalSeconds;
  final List<_Piece> pieces;
  _ConfettiPainter(this.t, this.totalSeconds, this.pieces);

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.30);
    final secs = t * totalSeconds;
    final fade =
        t < 0.75 ? 1.0 : (1 - (t - 0.75) / 0.25).clamp(0.0, 1.0).toDouble();

    for (final p in pieces) {
      final dx = math.cos(p.angle) * p.speed * secs;
      final dy = math.sin(p.angle) * p.speed * secs + 0.5 * 900 * secs * secs;

      canvas.save();
      canvas.translate(origin.dx + dx, origin.dy + dy);
      canvas.rotate(p.spin * secs);
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}