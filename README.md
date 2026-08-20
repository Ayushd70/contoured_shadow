# contoured_shadow

[![CI](https://github.com/Ayushd70/contoured_shadow/actions/workflows/ci.yml/badge.svg)](https://github.com/Ayushd70/contoured_shadow/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/contoured_shadow.svg)](https://pub.dev/packages/contoured_shadow)

Soft, **shape-following** shadows for Flutter — painted from the child's own
silhouette rather than a rectangle.

Wrap a cutout image, icon, or any widget with transparency. Opaque pixels cast
the shadow; transparent pixels do not. Ideal for product cutouts, badges, and
irregular shapes where `BoxShadow` looks wrong.

![Demo](https://raw.githubusercontent.com/Ayushd70/contoured_shadow/main/doc/demo.gif)

## Features

- Shadow contour matches the child's alpha / shape
- Configurable blur (isotropic or per-axis), offset, color, opacity, and blend mode
- Toggle shadows with `enabled` without removing the widget
- Implemented as a lightweight `RenderProxyBox` (no third-party deps)
- Alias `ContouredShadowWidget` for drop-in familiarity

## Install

```yaml
dependencies:
  contoured_shadow: ^0.2.0
```

```dart
import 'package:contoured_shadow/contoured_shadow.dart';
```

## Usage

```dart
ContouredShadow(
  blurSigma: 8,
  offset: const Offset(0, 6),
  opacity: 0.3,
  child: Image.asset(
    'assets/product_cutout.png',
    width: 180,
  ),
)
```

The child's **opacity and shape define the shadow contour**. Fully transparent
regions cast no shadow; anti-aliased edges produce a soft matching outline.

### Asymmetric blur

`blurSigma` remains the primary radius for both axes. Set `blurSigmaX` and/or
`blurSigmaY` to override an axis; any missing axis falls back to `blurSigma`.

```dart
ContouredShadow(
  blurSigma: 6,
  blurSigmaX: 14, // wide horizontal soft edge
  blurSigmaY: 4,  // tighter vertical blur
  offset: const Offset(0, 8),
  child: Icon(Icons.star, size: 64),
)
```

### Disable without removing the wrap

```dart
ContouredShadow(
  enabled: showShadow,
  child: myWidget,
)
```

### Customization

| Parameter | Default | Description |
| --- | --- | --- |
| `child` | required | Widget whose silhouette becomes the shadow |
| `enabled` | `true` | When `false`, paints child only (no shadow) |
| `blurSigma` | `5` | Primary Gaussian blur radius (both axes) |
| `blurSigmaX` | `null` | Optional X-axis blur; overrides `blurSigma` when set |
| `blurSigmaY` | `null` | Optional Y-axis blur; overrides `blurSigma` when set |
| `offset` | `Offset(0, 4)` | Shadow displacement relative to the child |
| `shadowColor` | black | Base shadow color (before opacity) |
| `opacity` | `0.25` | Shadow opacity (0–1) |
| `blendMode` | `BlendMode.srcIn` | Blend mode for the shadow color filter |

## Example

See the [`example/`](example/) app for icons and shaped surfaces with contoured
shadows, including an enabled toggle and asymmetric blur demo.

## License

MIT
