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
///
/// Blur precedence: [blurSigma] is the primary radius for both axes. When
/// [blurSigmaX] and/or [blurSigmaY] are non-null, those values override the
/// corresponding axis; a missing axis falls back to [blurSigma].
class ContouredShadow extends SingleChildRenderObjectWidget {
  /// Creates a shape-following soft shadow around [child].
  const ContouredShadow({
    super.key,
    required Widget child,
    this.enabled = true,
    this.blurSigma = 5,
    this.blurSigmaX,
    this.blurSigmaY,
    this.offset = const Offset(0, 4),
    this.shadowColor = const Color(0xFF000000),
    this.opacity = 0.25,
    this.blendMode = BlendMode.srcIn,
  }) : assert(blurSigma >= 0),
       assert(blurSigmaX == null || blurSigmaX >= 0),
       assert(blurSigmaY == null || blurSigmaY >= 0),
       assert(opacity >= 0 && opacity <= 1),
       super(child: child);

  /// When `false`, only [child] is painted (no shadow layer).
  final bool enabled;

  /// Gaussian blur radius applied to both axes unless overridden.
  ///
  /// Prefer this for isotropic blur. Use [blurSigmaX] / [blurSigmaY] only when
  /// you need per-axis control; each non-null axis overrides [blurSigma].
  final double blurSigma;

  /// Optional horizontal blur radius. When non-null, overrides [blurSigma] for
  /// the X axis.
  final double? blurSigmaX;

  /// Optional vertical blur radius. When non-null, overrides [blurSigma] for
  /// the Y axis.
  final double? blurSigmaY;

  /// Displacement of the shadow relative to the child.
  final Offset offset;

  /// Base color of the shadow before [opacity] is applied.
  final Color shadowColor;

  /// Opacity of the shadow (0–1). Combined with [shadowColor].
  final double opacity;

  /// Blend mode used by the shadow [ColorFilter]. Defaults to [BlendMode.srcIn].
  final BlendMode blendMode;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderContouredShadow(
      enabled: enabled,
      blurSigma: blurSigma,
      blurSigmaX: blurSigmaX,
      blurSigmaY: blurSigmaY,
      offset: offset,
      shadowColor: shadowColor,
      opacity: opacity,
      blendMode: blendMode,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderContouredShadow renderObject,
  ) {
    renderObject
      ..enabled = enabled
      ..blurSigma = blurSigma
      ..blurSigmaX = blurSigmaX
      ..blurSigmaY = blurSigmaY
      ..offset = offset
      ..shadowColor = shadowColor
      ..opacity = opacity
      ..blendMode = blendMode;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'))
      ..add(DoubleProperty('blurSigma', blurSigma))
      ..add(DoubleProperty('blurSigmaX', blurSigmaX, defaultValue: null))
      ..add(DoubleProperty('blurSigmaY', blurSigmaY, defaultValue: null))
      ..add(DiagnosticsProperty<Offset>('offset', offset))
      ..add(ColorProperty('shadowColor', shadowColor))
      ..add(DoubleProperty('opacity', opacity))
      ..add(EnumProperty<BlendMode>('blendMode', blendMode));
  }
}

/// Alias for [ContouredShadow], matching the original fashion-app name.
typedef ContouredShadowWidget = ContouredShadow;

/// Paints a blurred, tinted copy of its child as a soft contour shadow.
class RenderContouredShadow extends RenderProxyBox {
  /// Creates a render object that paints a contoured shadow under its child.
  RenderContouredShadow({
    required bool enabled,
    required double blurSigma,
    double? blurSigmaX,
    double? blurSigmaY,
    required Offset offset,
    required Color shadowColor,
    required double opacity,
    required BlendMode blendMode,
  }) {
    _enabled = enabled;
    _blurSigma = blurSigma;
    _blurSigmaX = blurSigmaX;
    _blurSigmaY = blurSigmaY;
    _offset = offset;
    _shadowColor = shadowColor;
    _opacity = opacity;
    _blendMode = blendMode;
  }

  late bool _enabled;
  late double _blurSigma;
  double? _blurSigmaX;
  double? _blurSigmaY;
  late Offset _offset;
  late Color _shadowColor;
  late double _opacity;
  late BlendMode _blendMode;
  ui.ImageFilter? _blurFilter;

  /// When `false`, only the child is painted.
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    markNeedsPaint();
  }

  /// Gaussian blur radius applied when per-axis values are null.
  double get blurSigma => _blurSigma;
  set blurSigma(double value) {
    if (_blurSigma == value) return;
    _blurSigma = value;
    _blurFilter = null;
    markNeedsPaint();
  }

  /// Optional horizontal blur override; falls back to [blurSigma] when null.
  double? get blurSigmaX => _blurSigmaX;
  set blurSigmaX(double? value) {
    if (_blurSigmaX == value) return;
    _blurSigmaX = value;
    _blurFilter = null;
    markNeedsPaint();
  }

  /// Optional vertical blur override; falls back to [blurSigma] when null.
  double? get blurSigmaY => _blurSigmaY;
  set blurSigmaY(double? value) {
    if (_blurSigmaY == value) return;
    _blurSigmaY = value;
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

  /// Blend mode used by the shadow color filter.
  BlendMode get blendMode => _blendMode;
  set blendMode(BlendMode value) {
    if (_blendMode == value) return;
    _blendMode = value;
    markNeedsPaint();
  }

  double get _resolvedBlurSigmaX => _blurSigmaX ?? _blurSigma;

  double get _resolvedBlurSigmaY => _blurSigmaY ?? _blurSigma;

  double get _maxResolvedBlurSigma {
    final x = _resolvedBlurSigmaX;
    final y = _resolvedBlurSigmaY;
    return x > y ? x : y;
  }

  ui.ImageFilter get _resolvedBlurFilter {
    return _blurFilter ??= ui.ImageFilter.blur(
      sigmaX: _resolvedBlurSigmaX,
      sigmaY: _resolvedBlurSigmaY,
      tileMode: TileMode.decal,
    );
  }

  Color get _resolvedShadowColor => _shadowColor.withValues(alpha: _opacity);

  /// Extra padding so the blur and offset are not clipped by the layer.
  double get _blurPadding => _maxResolvedBlurSigma * 3;

  @override
  Rect get paintBounds {
    final base = Offset.zero & size;
    if (child == null || !_enabled) return base;
    final shadowBounds = base.shift(_offset).inflate(_blurPadding);
    return base.expandToInclude(shadowBounds);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;

    final blurX = _resolvedBlurSigmaX;
    final blurY = _resolvedBlurSigmaY;
    final hasBlur = blurX > 0 || blurY > 0;

    if (_enabled && _opacity > 0 && (hasBlur || _offset != Offset.zero)) {
      final layerRect = paintBounds.shift(offset);
      final paint = Paint()
        ..colorFilter = ColorFilter.mode(_resolvedShadowColor, _blendMode);
      if (hasBlur) {
        paint.imageFilter = _resolvedBlurFilter;
      }

      context.canvas.saveLayer(layerRect, paint);
      context.paintChild(child, offset + _offset);
      context.canvas.restore();
    }

    context.paintChild(child, offset);
  }
}
