import 'dart:math' as math;

import 'package:contoured_shadow/contoured_shadow.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ContouredShadowDemo());
}

class ContouredShadowDemo extends StatelessWidget {
  const ContouredShadowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'contoured_shadow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4DFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F4F8),
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  bool _shadowEnabled = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contoured Shadow'),
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(
            'Shadows follow the opaque silhouette of the child — cutouts, '
            'icons, and irregular shapes look natural.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          const _DemoCard(
            title: 'Product cutout',
            child: ContouredShadow(
              blurSigma: 10,
              offset: Offset(0, 8),
              opacity: 0.28,
              child: _ProductSilhouette(),
            ),
          ),
          const SizedBox(height: 20),
          const _DemoCard(
            title: 'Icon badge',
            child: ContouredShadow(
              blurSigma: 6,
              offset: Offset(0, 5),
              shadowColor: Color(0xFF1B4DFF),
              opacity: 0.35,
              child: Icon(
                Icons.shopping_bag_rounded,
                size: 96,
                color: Color(0xFF1B4DFF),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _DemoCard(
            title: 'Shaped surface',
            child: ContouredShadow(
              blurSigma: 8,
              offset: Offset(2, 6),
              opacity: 0.22,
              child: _StarShape(),
            ),
          ),
          const SizedBox(height: 20),
          _DemoCard(
            title: 'Toggle enabled',
            child: Column(
              children: [
                ContouredShadow(
                  enabled: _shadowEnabled,
                  blurSigma: 10,
                  offset: const Offset(0, 8),
                  opacity: 0.3,
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 88,
                    color: Color(0xFFE11D48),
                  ),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Shadow enabled'),
                  value: _shadowEnabled,
                  onChanged: (value) => setState(() => _shadowEnabled = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _DemoCard(
            title: 'Asymmetric blur',
            child: ContouredShadow(
              blurSigma: 6,
              blurSigmaX: 18,
              blurSigmaY: 4,
              offset: Offset(0, 10),
              opacity: 0.3,
              child: Icon(
                Icons.hexagon_rounded,
                size: 96,
                color: Color(0xFF0F766E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 28),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}

/// Approximate apparel / product cutout without bundling a binary asset.
class _ProductSilhouette extends StatelessWidget {
  const _ProductSilhouette();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(140, 180),
      painter: _SilhouettePainter(color: const Color(0xFF2A3140)),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final body = Path()
      ..moveTo(size.width * 0.35, size.height * 0.08)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.0,
        size.width * 0.65,
        size.height * 0.08,
      )
      ..lineTo(size.width * 0.78, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.28,
        size.width * 0.88,
        size.height * 0.42,
      )
      ..lineTo(size.width * 0.82, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 1.0,
        size.width * 0.18,
        size.height * 0.92,
      )
      ..lineTo(size.width * 0.12, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.08,
        size.height * 0.28,
        size.width * 0.22,
        size.height * 0.22,
      )
      ..close();

    final neck = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.16),
          width: size.width * 0.22,
          height: size.height * 0.1,
        ),
      );

    final cutout = Path.combine(PathOperation.difference, body, neck);
    canvas.drawPath(cutout, paint);
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _StarShape extends StatelessWidget {
  const _StarShape();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(120, 120),
      painter: _StarPainter(color: const Color(0xFFFFB020)),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width * 0.45;
    final inner = size.width * 0.2;
    final path = Path();

    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + (i * math.pi / 5);
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color;
}
