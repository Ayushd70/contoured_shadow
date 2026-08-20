## 0.2.0

* Additive APIs on `ContouredShadow` / `RenderContouredShadow`:
  * `enabled` (default `true`) — when `false`, paints the child only.
  * Optional `blurSigmaX` / `blurSigmaY` — override per-axis blur; missing
    axes fall back to `blurSigma`.
  * `blendMode` (default `BlendMode.srcIn`) for the shadow color filter.
* `debugFillProperties` updated for the new parameters.
* Example demos for toggling shadow and asymmetric blur.
* Tests covering `enabled: false` and custom blur axes.

## 0.1.0

* Initial release of `contoured_shadow`.
* `ContouredShadow` (alias `ContouredShadowWidget`) paints a soft shadow that
  follows the child's opaque silhouette via a `RenderProxyBox`.
* Configurable `blurSigma`, `offset`, `shadowColor`, and `opacity`.
* Example app, widget tests, and documentation assets.
