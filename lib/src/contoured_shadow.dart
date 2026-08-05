import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Soft shadow that follows the child's opaque silhouette.
///
/// Unlike [BoxShadow], which is bound to a rectangle (or a simple shape),
/// [ContouredShadow] paints a blurred, colorized copy of the child and then
/// paints the child on top. The child's alpha channel and visible shape
/// therefore define the shadow contour — transparent pixels cast no shadow.
///
/// ```dart
/// ContouredShadow(
///   blurSigma: 8,
///   offset: const Offset(0, 6),
///   child: Image.asset('cutout.png'),
/// )
/// ```
class ContouredShadow extends SingleChildRenderObjectWidget {
  /// Creates a shape-following soft shadow around [child].
  const ContouredShadow({
    super.key,
    required Widget child,
    this.blurSigma = 5,
    this.offset = const Offset(0, 4),
    this.shadowColor = const Color(0xFF000000),
    this.opacity = 0.25,
  }) : assert(blurSigma >= 0),
       assert(opacity >= 0 && opacity <= 1),
       super(child: child);

  /// Gaussian blur radius applied to the shadow silhouette.
  final double blurSigma;

  /// Displacement of the shadow relative to the child.
  final Offset offset;

  /// Base color of the shadow before [opacity] is applied.
  final Color shadowColor;

  /// Opacity of the shadow (0–1). Combined with [shadowColor].
  final double opacity;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderContouredShadow(
      blurSigma: blurSigma,
      offset: offset,
      shadowColor: shadowColor,
      opacity: opacity,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderContouredShadow renderObject,
  ) {
    renderObject
      ..blurSigma = blurSigma
      ..offset = offset
      ..shadowColor = shadowColor
      ..opacity = opacity;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('blurSigma', blurSigma))
      ..add(DiagnosticsProperty<Offset>('offset', offset))
      ..add(ColorProperty('shadowColor', shadowColor))
      ..add(DoubleProperty('opacity', opacity));
  }
}

/// Alias for [ContouredShadow], matching the original fashion-app name.
typedef ContouredShadowWidget = ContouredShadow;

/// Paints a blurred, tinted copy of its child as a soft contour shadow.
class RenderContouredShadow extends RenderProxyBox {
  /// Creates a render object that paints a contoured shadow under its child.
  RenderContouredShadow({
    required double blurSigma,
    required Offset offset,
    required Color shadowColor,
    required double opacity,
  }) {
    _blurSigma = blurSigma;
    _offset = offset;
    _shadowColor = shadowColor;
    _opacity = opacity;
  }

  late double _blurSigma;
  late Offset _offset;
  late Color _shadowColor;
  late double _opacity;
  ui.ImageFilter? _blurFilter;

  /// Gaussian blur radius applied to the shadow silhouette.
  double get blurSigma => _blurSigma;
  set blurSigma(double value) {
    if (_blurSigma == value) return;
    _blurSigma = value;
    _blurFilter = null;
    markNeedsPaint();
  }

  /// Displacement of the shadow relative to the child.
  Offset get offset => _offset;
  set offset(Offset value) {
    if (_offset == value) return;
    _offset = value;
    markNeedsPaint();
  }

  /// Base color of the shadow before [opacity] is applied.
  Color get shadowColor => _shadowColor;
  set shadowColor(Color value) {
    if (_shadowColor == value) return;
    _shadowColor = value;
    markNeedsPaint();
  }

  /// Opacity of the shadow (0–1).
  double get opacity => _opacity;
  set opacity(double value) {
    if (_opacity == value) return;
    _opacity = value;
    markNeedsPaint();
  }

  ui.ImageFilter get _resolvedBlurFilter {
    return _blurFilter ??= ui.ImageFilter.blur(
      sigmaX: _blurSigma,
      sigmaY: _blurSigma,
      tileMode: TileMode.decal,
    );
  }

  Color get _resolvedShadowColor => _shadowColor.withValues(alpha: _opacity);

  /// Extra padding so the blur and offset are not clipped by the layer.
  double get _blurPadding => _blurSigma * 3;

  @override
  Rect get paintBounds {
    final base = Offset.zero & size;
    if (child == null) return base;
    final shadowBounds = base.shift(_offset).inflate(_blurPadding);
    return base.expandToInclude(shadowBounds);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;

    if (_opacity > 0 && (_blurSigma > 0 || _offset != Offset.zero)) {
      final layerRect = paintBounds.shift(offset);
      final paint = Paint()
        ..colorFilter = ColorFilter.mode(_resolvedShadowColor, BlendMode.srcIn);
      if (_blurSigma > 0) {
        paint.imageFilter = _resolvedBlurFilter;
      }

      context.canvas.saveLayer(layerRect, paint);
      context.paintChild(child, offset + _offset);
      context.canvas.restore();
    }

    context.paintChild(child, offset);
  }
}
