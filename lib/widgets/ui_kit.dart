import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.borderColor,
    this.color,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? borderColor;
  final Color? color;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    return Container(
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color ?? sc.bgRaised,
        border: Border.all(color: borderColor ?? sc.border),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key, this.color, this.margin});

  final Color? color;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 42,
          height: 4.5,
          margin: margin ?? const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color ?? context.sc.bgRaised2,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
}

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.onTap,
    this.hPad = 12,
    this.vPad = 6,
    this.fontSize = 12,
    this.icon,
  });

  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;
  final double hPad;
  final double vPad;
  final double fontSize;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fg),
            const SizedBox(width: 5),
          ],
          Text(label, style: AppTheme.s(fontSize, weight: FontWeight.w600, color: fg)),
        ],
      ),
    );

    if (onTap == null) return body;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: body);
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.bg,
    this.fg,
    this.height = 54,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final Color? bg;
  final Color? fg;
  final double height;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    final f = fg ?? sc.onEmber;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: bg ?? sc.ember,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: (bg ?? sc.ember).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: f), const SizedBox(width: 10)],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTheme.d(15, weight: FontWeight.w600, color: f, letterSpacing: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    final c = color ?? sc.text;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: sc.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: c),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.d(13, weight: FontWeight.w600, color: c, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}

class RoundBtn extends StatelessWidget {
  const RoundBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.color,
    this.bg,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? color;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg ?? sc.bgRaised,
          shape: BoxShape.circle,
          border: Border.all(color: sc.border),
        ),
        child: Center(
          child: Icon(icon, size: size * 0.48, color: color ?? sc.text),
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle,
    this.titleSize = 22,
    this.actions = const [],
  });

  final String title;
  final VoidCallback onBack;
  final String? subtitle;
  final double titleSize;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;
    return Row(
      children: [
        RoundBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack, size: 38),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.d(titleSize, weight: FontWeight.w700, color: sc.text, letterSpacing: 1.5),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTheme.s(12, color: sc.textSecondary)),
              ],
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}

class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, required this.color, this.size = 11, this.spacing = 2.5});

  final String text;
  final Color color;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTheme.d(size, weight: FontWeight.w600, color: color, letterSpacing: spacing));
}
