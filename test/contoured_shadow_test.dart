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
    expect(defaults.blurSigma, 5);
    expect(defaults.offset, const Offset(0, 4));
    expect(defaults.shadowColor, const Color(0xFF000000));
    expect(defaults.opacity, 0.25);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContouredShadow(
            blurSigma: 12,
            offset: Offset(2, 8),
            shadowColor: Color(0xFF112233),
            opacity: 0.4,
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
    expect(custom.offset, const Offset(2, 8));
    expect(custom.shadowColor, const Color(0xFF112233));
    expect(custom.opacity, 0.4);
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

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContouredShadow(
            blurSigma: 9,
            opacity: 0.5,
            child: Icon(Icons.star, size: 48),
          ),
        ),
      ),
    );

    render =
        tester.renderObject(find.byType(ContouredShadow))
            as RenderContouredShadow;
    expect(render.blurSigma, 9);
    expect(render.opacity, 0.5);
  });

  test('asserts on invalid blurSigma and opacity', () {
    expect(
      () => ContouredShadow(blurSigma: -1, child: const SizedBox()),
      throwsAssertionError,
    );
    expect(
      () => ContouredShadow(opacity: 1.5, child: const SizedBox()),
      throwsAssertionError,
    );
  });
}
