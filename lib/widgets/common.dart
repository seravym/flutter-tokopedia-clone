import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../screens/cart/cart_page.dart';
import '../services/cart_store.dart';

class TokoLogo extends StatelessWidget {
  final double size;
  final bool light;
  final bool showText;
  const TokoLogo({
    super.key,
    this.size = 44,
    this.light = false,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: light ? Colors.white : AppColors.green,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: softShadow(0.12),
      ),
      child: Icon(
        Icons.shopping_bag_rounded,
        color: light ? AppColors.green : Colors.white,
        size: size * 0.56,
      ),
    );
    if (!showText) return tile;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        SizedBox(width: size * 0.28),
        Text(
          'tokopedia',
          style: T.s(
            size * 0.62,
            w: FontWeight.w800,
            c: light ? Colors.white : AppColors.green,
            ls: -1.2,
          ),
        ),
      ],
    );
  }
}

class NetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  const NetImage(this.url, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImgFallback();
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, __) => const Skeleton(radius: 0),
      errorWidget: (_, __, ___) => const _ImgFallback(),
    );
  }
}

class _ImgFallback extends StatelessWidget {
  const _ImgFallback();
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.mintSoft,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.sub,
        ),
      );
}

class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;
  const Skeleton({super.key, this.width, this.height, this.radius = 12});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFFE9EFEB),
            const Color(0xFFF6F9F7),
            _c.value,
          ),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final double height;
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final Color bg = outlined
        ? Colors.white
        : (enabled ? AppColors.green : const Color(0xFFCBD5CF));
    final Color fg = outlined
        ? (enabled ? AppColors.green : AppColors.sub)
        : Colors.white;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: enabled ? AppColors.green : AppColors.line,
                    width: 1.5,
                  ),
                )
              : null,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: T.s(15, w: FontWeight.w700, c: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final VoidCallback? onTap;
  const Pill(
    this.text, {
    super.key,
    this.bg = AppColors.mint,
    this.fg = AppColors.green,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: 4),
              ],
              Text(text, style: T.s(12, w: FontWeight.w700, c: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscountBadge extends StatelessWidget {
  final double percent;
  const DiscountBadge(this.percent, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.peachSoft,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${percent.round()}%',
          style: T.s(11, w: FontWeight.w800, c: AppColors.peach),
        ),
      );
}

class RatingRow extends StatelessWidget {
  final double rating;
  final double size;
  const RatingRow(this.rating, {super.key, this.size = 14});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: AppColors.star, size: size + 2),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: T.s(size - 1, w: FontWeight.w700),
          ),
        ],
      );
}

class Stars extends StatelessWidget {
  final int value;
  final double size;
  const Stars(this.value, {super.key, this.size = 14});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (i) => Icon(
            Icons.star_rounded,
            size: size,
            color: i < value ? AppColors.star : AppColors.line,
          ),
        ),
      );
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.peachSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 40,
                  color: AppColors.peach,
                ),
              ),
              const SizedBox(height: 20),
              Text('Yah, gagal memuat 😢', style: T.h3),
              const SizedBox(height: 6),
              Text(message, textAlign: TextAlign.center, style: T.small),
              const SizedBox(height: 20),
              SizedBox(
                width: 180,
                child: PrimaryButton(
                  label: 'Coba lagi',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ),
            ],
          ),
        ),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: AppColors.green),
              ),
              const SizedBox(height: 22),
              Text(title, style: T.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center, style: T.small),
              if (actionLabel != null) ...[
                const SizedBox(height: 22),
                SizedBox(
                  width: 200,
                  child: PrimaryButton(
                    label: actionLabel!,
                    onPressed: onAction,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

class CartIconButton extends StatelessWidget {
  final Color color;
  final Color background;
  const CartIconButton({
    super.key,
    this.color = AppColors.ink,
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartStore.instance,
      builder: (context, _) {
        final n = CartStore.instance.totalQty;
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CartPage(showBack: true)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: color,
                  size: 22,
                ),
              ),
              if (n > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.peach,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      n > 99 ? '99+' : '$n',
                      textAlign: TextAlign.center,
                      style: T.s(10, w: FontWeight.w800, c: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class QtyStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final VoidCallback? onMaxReached;
  const QtyStepper({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    this.min = 1,
    this.onMaxReached,
  });

  Widget _btn(IconData icon, VoidCallback? onTap) => InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 18,
            color: onTap == null ? AppColors.line : AppColors.green,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(
            Icons.remove_rounded,
            value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: T.s(14, w: FontWeight.w800),
            ),
          ),
          _btn(Icons.add_rounded, () {
            if (value < max) {
              onChanged(value + 1);
            } else {
              onMaxReached?.call();
            }
          }),
        ],
      ),
    );
  }
}

void toast(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_rounded,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Icon(icon, color: AppColors.mint, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: T.s(13, w: FontWeight.w600, c: Colors.white),
            ),
          ),
        ],
      ),
      action: actionLabel == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              textColor: const Color(0xFF7CE0A5),
              onPressed: onAction ?? () {},
            ),
    ),
  );
}