import 'package:flutter/material.dart';

class MaxWidth extends StatelessWidget {
  final double maxWidth;
  final Widget child;
  const MaxWidth({super.key, required this.maxWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final pad = width > maxWidth ? (width - maxWidth) / 2 : 16.0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: 24),
          child: child,
        );
      },
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const PrimaryButton(
      {super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.check_circle_outline),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(label),
        ),
      ),
    );
  }
}

// ================= Branded Background (Black / Red / White / Gold) =================

class BrandedBackground extends StatelessWidget {
  final Widget child;
  final bool paintStripes;
  const BrandedBackground(
      {super.key, required this.child, this.paintStripes = true});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B0B0C), Color(0xFF111215)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft gold glow (top right)
          const Positioned(
            right: -80,
            top: -80,
            child: _GlowCircle(color: Color(0x33B68D40), size: 240),
          ),
          // Soft red glow (bottom left)
          const Positioned(
            left: -90,
            bottom: -90,
            child: _GlowCircle(color: Color(0x33C1121F), size: 300),
          ),
          if (paintStripes)
            const IgnorePointer(
              child: CustomPaint(
                painter: _RibbonStripesPainter(
                  gold: Color(0x1FB68D40),
                  red: Color(0x14C1121F),
                ),
              ),
            ),
          // Subtle floating icons
          const _FloatingGlyph(
              icon: Icons.shield_outlined,
              dx: .15,
              dy: .22,
              size: 46,
              opacity: .07),
          const _FloatingGlyph(
              icon: Icons.receipt_long_outlined,
              dx: .78,
              dy: .28,
              size: 40,
              opacity: .06),
          const _FloatingGlyph(
              icon: Icons.person_outline,
              dx: .30,
              dy: .78,
              size: 42,
              opacity: .07),

          // Foreground content wrapper for consistent readable padding
          Container(color: scheme.surface.withOpacity(.02), child: child),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}

class _FloatingGlyph extends StatelessWidget {
  final IconData icon;
  final double dx;
  final double dy;
  final double size;
  final double opacity;
  const _FloatingGlyph(
      {required this.icon,
      required this.dx,
      required this.dy,
      required this.size,
      required this.opacity});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Positioned(
          left: c.maxWidth * dx,
          top: c.maxHeight * dy,
          child: Opacity(
            opacity: opacity,
            child: Icon(icon, size: size, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _RibbonStripesPainter extends CustomPainter {
  final Color gold;
  final Color red;
  const _RibbonStripesPainter({required this.gold, required this.red});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Gold diagonal ribbons
    paint.color = gold;
    final w = size.width;
    final h = size.height;

    final path1 = Path()
      ..moveTo(w * -0.1, h * 0.15)
      ..lineTo(w * 0.6, h * -0.1)
      ..lineTo(w * 0.7, h * 0.08)
      ..lineTo(w * 0.0, h * 0.33)
      ..close();
    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(w * 0.4, h * 1.1)
      ..lineTo(w * 1.2, h * 0.65)
      ..lineTo(w * 1.15, h * 0.55)
      ..lineTo(w * 0.35, h * 1.0)
      ..close();
    canvas.drawPath(path2, paint);

    // Red accent ribbon
    paint.color = red;
    final path3 = Path()
      ..moveTo(w * -0.2, h * 0.85)
      ..lineTo(w * 0.35, h * 0.55)
      ..lineTo(w * 0.3, h * 0.48)
      ..lineTo(w * -0.25, h * 0.78)
      ..close();
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
