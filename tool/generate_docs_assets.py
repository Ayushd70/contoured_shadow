#!/usr/bin/env python3
"""Generate docs screenshots and demo GIF for contoured_shadow."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "doc"
SHOTS = OUT / "screenshots"
W, H = 780, 520
BG = (242, 244, 248, 255)
SURFACE = (255, 255, 255, 255)
TEXT = (28, 32, 40)
MUTED = (100, 110, 125)
PRIMARY = (27, 77, 255)
SILHOUETTE = (42, 49, 64, 255)
STAR = (255, 176, 32, 255)


def font(size: int, bold: bool = False) -> ImageFont.ImageFont:
    candidates = [
        (
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
            if bold
            else "/System/Library/Fonts/Supplemental/Arial.ttf"
        ),
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


def product_cutout(size: tuple[int, int] = (160, 210)) -> Image.Image:
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Garment-like silhouette
    pts = [
        (w * 0.35, h * 0.08),
        (w * 0.5, h * 0.02),
        (w * 0.65, h * 0.08),
        (w * 0.78, h * 0.22),
        (w * 0.90, h * 0.30),
        (w * 0.86, h * 0.42),
        (w * 0.82, h * 0.92),
        (w * 0.50, h * 0.98),
        (w * 0.18, h * 0.92),
        (w * 0.14, h * 0.42),
        (w * 0.10, h * 0.30),
        (w * 0.22, h * 0.22),
    ]
    draw.polygon(pts, fill=SILHOUETTE)
    # Neck hole
    cx, cy = w * 0.5, h * 0.16
    draw.ellipse(
        (cx - w * 0.11, cy - h * 0.05, cx + w * 0.11, cy + h * 0.05),
        fill=(0, 0, 0, 0),
    )
    return img


def star_shape(size: tuple[int, int] = (120, 120)) -> Image.Image:
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = w / 2, h / 2
    outer, inner = w * 0.45, w * 0.2
    pts = []
    for i in range(10):
        r = outer if i % 2 == 0 else inner
        angle = -math.pi / 2 + i * math.pi / 5
        pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(pts, fill=STAR)
    return img


def bag_icon(size: tuple[int, int] = (110, 110)) -> Image.Image:
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Simple shopping-bag silhouette
    draw.rounded_rectangle(
        (w * 0.18, h * 0.32, w * 0.82, h * 0.88),
        radius=14,
        fill=PRIMARY + (255,),
    )
    draw.arc(
        (w * 0.32, h * 0.12, w * 0.68, h * 0.48),
        start=200,
        end=340,
        fill=PRIMARY + (255,),
        width=10,
    )
    return img


def contoured_shadow(
    subject: Image.Image,
    origin: tuple[int, int],
    blur: float = 10,
    offset: tuple[int, int] = (0, 8),
    opacity: float = 0.28,
    tint: tuple[int, int, int] = (0, 0, 0),
) -> tuple[Image.Image, Image.Image]:
    """Return (shadow_layer, subject_layer) placed into full-frame canvases."""
    ox, oy = origin
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    # Tint subject alpha into shadow color
    alpha = subject.split()[3]
    tinted = Image.new("RGBA", subject.size, tint + (0,))
    tinted.putalpha(alpha.point(lambda a: int(a * opacity)))
    shadow.paste(tinted, (ox + offset[0], oy + offset[1]), tinted)
    blurred = shadow.filter(ImageFilter.GaussianBlur(blur))

    fg = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    fg.paste(subject, (ox, oy), subject)
    return blurred, fg


def make_frame(pulse: float = 0.0) -> Image.Image:
    """pulse 0 = resting, 1 = slightly deeper / softer shadow."""
    pulse = max(0.0, min(1.0, pulse))
    img = Image.new("RGBA", (W, H), BG)
    draw = ImageDraw.Draw(img)

    # Card surface
    card = (48, 56, 732, 456)
    draw.rounded_rectangle(card, radius=28, fill=SURFACE)
    draw.text((76, 78), "Contoured Shadow", font=font(28, bold=True), fill=TEXT)
    draw.text(
        (76, 118),
        "Shadow follows the opaque silhouette",
        font=font(18),
        fill=MUTED,
    )

    blur = 8 + 6 * pulse
    opacity = 0.22 + 0.12 * pulse
    dy = int(2 * pulse)

    items = [
        (product_cutout(), (90, 180), (0, 8 + dy), blur, opacity, (0, 0, 0)),
        (
            bag_icon(),
            (340, 220),
            (0, 5 + dy),
            blur * 0.7,
            opacity + 0.05,
            PRIMARY,
        ),
        (star_shape(), (540, 210), (2, 6 + dy), blur * 0.85, opacity, (0, 0, 0)),
    ]

    for subject, origin, off, b, op, tint in items:
        shadow, fg = contoured_shadow(
            subject, origin, blur=b, offset=off, opacity=op, tint=tint
        )
        img = Image.alpha_composite(img, shadow)
        img = Image.alpha_composite(img, fg)

    ImageDraw.Draw(img).text(
        (76, H - 52),
        "Cutout  ·  Icon  ·  Shape",
        font=font(16),
        fill=MUTED,
    )
    return img


def save_png(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(path, "PNG", optimize=True)


def make_gif(path: Path) -> None:
    frames = []
    steps = [0.0, 0.15, 0.35, 0.55, 0.75, 1.0, 0.7, 0.4, 0.15, 0.0]
    durations = [500, 80, 80, 80, 80, 420, 90, 90, 90, 360]
    for p in steps:
        frames.append(make_frame(p).convert("P", palette=Image.ADAPTIVE))
    path.parent.mkdir(parents=True, exist_ok=True)
    frames[0].save(
        path,
        save_all=True,
        append_images=frames[1:],
        duration=durations,
        loop=0,
        optimize=True,
    )


def main() -> None:
    SHOTS.mkdir(parents=True, exist_ok=True)
    save_png(make_frame(0.0), SHOTS / "resting.png")
    make_gif(OUT / "demo.gif")
    print(f"Wrote {SHOTS / 'resting.png'}")
    print(f"Wrote {OUT / 'demo.gif'}")


if __name__ == "__main__":
    main()
