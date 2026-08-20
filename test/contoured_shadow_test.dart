import 'package:contoured_shadow/contoured_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ContouredShadow(child: Text('Hello shadow'))),
      ),
    );

    expect(find.text('Hello shadow'), findsOneWidget);
  });

  testWidgets('ContouredShadowWidget alias constructs ContouredShadow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ContouredShadowWidget(child: Text('Aliased'))),
      ),
    );

    expect(find.byType(ContouredShadow), findsOneWidget);
    expect(find.text('Aliased'), findsOneWidget);
  });

  testWidgets('applies default and custom shadow parameters', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContouredShadow(
            child: SizedBox(
              width: 40,
              height: 40,
              child: ColoredBox(color: Colors.red),
            ),
          ),
        ),
      ),
    );

    final defaults =
        tester.renderObject(find.byType(ContouredShadow))
            as RenderContouredShadow;
    expect(defaults.enabled, isTrue);
    expect(defaults.blurSigma, 5);
    expect(defaults.blurSigmaX, isNull);
    expect(defaults.blurSigmaY, isNull);
    expect(defaults.offset, const Offset(0, 4));
    expect(defaults.shadowColor, const Color(0xFF000000));
    expect(defaults.opacity, 0.25);
    expect(defaults.blendMode, BlendMode.srcIn);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContouredShadow(
            blurSigma: 12,
            blurSigmaX: 16,
            blurSigmaY: 4,
            offset: Offset(2, 8),
            shadowColor: Color(0xFF112233),
            opacity: 0.4,
            blendMode: BlendMode.srcOver,
            child: SizedBox(
              width: 40,
              height: 40,
              child: ColoredBox(color: Colors.red),
            ),
          ),
        ),
      ),
    );

    final custom =
        tester.renderObject(find.byType(ContouredShadow))
            as RenderContouredShadow;
    expect(custom.blurSigma, 12);
    expect(custom.blurSigmaX, 16);
    expect(custom.blurSigmaY, 4);
    expect(custom.offset, const Offset(2, 8));
    expect(custom.shadowColor, const Color(0xFF112233));
    expect(custom.opacity, 0.4);
    expect(custom.blendMode, BlendMode.srcOver);
  });

  testWidgets('enabled:false still renders child without expanding bounds', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ContouredShadow(
              enabled: false,
              blurSigma: 10,
              offset: Offset(0, 6),
              child: SizedBox(
                width: 50,
                height: 50,
                child: ColoredBox(color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(SizedBox), findsOneWidget);

    final render =
        tester.renderObject(find.byType(ContouredShadow))
            as RenderContouredShadow;
    expect(render.enabled, isFalse);
    expect(render.paintBounds, const Rect.fromLTWH(0, 0, 50, 50));
  });

  testWidgets('custom blur axes expand paintBounds using max axis', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ContouredShadow(
              blurSigma: 2,
              blurSigmaX: 20,
              blurSigmaY: 4,
              offset: Offset.zero,
              child: SizedBox(
                width: 50,
                height: 50,
                child: ColoredBox(color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );

    final asymmetric =
        tester.renderObject(find.byType(ContouredShadow))
            as RenderContouredShadow;
    expect(asymmetric.blurSigmaX, 20);
    expect(asymmetric.blurSigmaY, 4);
    // Padding uses max(resolvedX, resolvedY) * 3 → 20 * 3 = 60 on each side.
    expect(asymmetric.paintBounds.width, closeTo(170, 0.001));
    expect(asymmetric.paintBounds.height, closeTo(170, 0.001));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ContouredShadow(
              blurSigma: 10,
              blurSigmaX: 2,
              offset: Offset.zero,
              child: SizedBox(
                width: 50,
                height: 50,
                child: ColoredBox(color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );

    final partial =
        tester.renderObject(find.byType(ContouredShadow))
            as RenderContouredShadow;
    expect(partial.blurSigmaX, 2);
    expect(partial.blurSigmaY, isNull);
    // max(2, 10) * 3 = 30 padding → 50 + 60 = 110.
    expect(partial.paintBounds.width, closeTo(110, 0.001));
  });

  testWidgets('paintBounds expand for blur and offset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ContouredShadow(
              blurSigma: 10,
              offset: Offset(0, 6),
              child: SizedBox(
                width: 50,
                height: 50,
                child: ColoredBox(color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );

    final render =
        tester.renderObject(find.byType(ContouredShadow))
            as RenderContouredShadow;
    final bounds = render.paintBounds;

    expect(bounds.width, greaterThan(50));
    expect(bounds.height, greaterThan(50));
    expect(bounds.bottom, greaterThan(50));
  });

  testWidgets('updates render object when props change', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContouredShadow(
            blurSigma: 3,
            child: Icon(Icons.star, size: 48),
          ),
        ),
      ),
    );

    var render =
        tester.renderObject(find.byType(ContouredShadow))
            as RenderContouredShadow;
    expect(render.blurSigma, 3);
    expect(render.enabled, isTrue);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContouredShadow(
            enabled: false,
            blurSigma: 9,
            blurSigmaX: 11,
            opacity: 0.5,
            blendMode: BlendMode.multiply,
            child: Icon(Icons.star, size: 48),
          ),
        ),
      ),
    );

    render =
        tester.renderObject(find.byType(ContouredShadow))
            as RenderContouredShadow;
    expect(render.enabled, isFalse);
    expect(render.blurSigma, 9);
    expect(render.blurSigmaX, 11);
    expect(render.opacity, 0.5);
    expect(render.blendMode, BlendMode.multiply);
  });

  test('asserts on invalid blurSigma and opacity', () {
    expect(
      () => ContouredShadow(blurSigma: -1, child: const SizedBox()),
      throwsAssertionError,
    );
    expect(
      () => ContouredShadow(blurSigmaX: -1, child: const SizedBox()),
      throwsAssertionError,
    );
    expect(
      () => ContouredShadow(blurSigmaY: -0.5, child: const SizedBox()),
      throwsAssertionError,
    );
    expect(
      () => ContouredShadow(opacity: 1.5, child: const SizedBox()),
      throwsAssertionError,
    );
  });
}
