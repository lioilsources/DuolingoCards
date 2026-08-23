#!/usr/bin/env python3
"""Render the two graphics Google Play requires but the App Store does not.

    python3 tools/play_graphics.py

  store/play_graphics/icon-512.png      512x512, no alpha — the store icon
  store/play_graphics/feature-1024x500.png  the banner at the top of the listing

Play rejects an icon with an alpha channel, and the listing cannot be
submitted at all without a feature graphic. Both are derived from
assets/icon/icon_master.png so they cannot drift from the app's own icon.

The banner deliberately carries no screenshot: Play crops it hard on small
screens and overlays a play button on it in some placements, so anything fine
enough to read is the first thing lost.
"""
import pathlib

from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
ICON = ROOT / "assets" / "icon" / "icon_master.png"
OUT = ROOT / "store" / "play_graphics"

FONT = "/System/Library/Fonts/SFNS.ttf"
INK = (24, 32, 46)
MUTED = (108, 122, 143)
# The deck palette's lavender and rose, so the listing matches the app.
BG_LEFT = (243, 240, 248)
BG_RIGHT = (251, 234, 234)


def font(size, weight=None):
    f = ImageFont.truetype(FONT, size)
    if weight is not None:
        try:
            f.set_variation_by_axes([weight])
        except Exception:
            pass
    return f


def flatten(im, bg=(255, 255, 255)):
    if im.mode != "RGBA":
        return im.convert("RGB")
    out = Image.new("RGB", im.size, bg)
    out.paste(im, (0, 0), im)
    return out


def store_icon():
    icon = flatten(Image.open(ICON)).resize((512, 512), Image.LANCZOS)
    path = OUT / "icon-512.png"
    icon.save(path, "PNG")
    return path, icon.size


def feature_graphic():
    w, h = 1024, 500
    canvas = Image.new("RGB", (w, h), BG_LEFT)
    draw = ImageDraw.Draw(canvas)
    for x in range(w):
        t = x / w
        draw.line([(x, 0), (x, h)],
                  fill=tuple(int(a + (b - a) * t)
                             for a, b in zip(BG_LEFT, BG_RIGHT)))

    icon = flatten(Image.open(ICON), BG_LEFT).resize((260, 260), Image.LANCZOS)
    mask = Image.new("L", icon.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, icon.width - 1, icon.height - 1], radius=58, fill=255)
    canvas.paste(icon, (92, (h - icon.height) // 2), mask)

    x = 92 + 260 + 68
    draw.text((x, 176), "Lexify", font=font(96, 700), fill=INK)
    draw.text((x, 292), "Vocabulary flashcards", font=font(38, 400), fill=MUTED)
    draw.text((x, 344), "17 languages · 14 decks · offline",
              font=font(30, 400), fill=MUTED)

    path = OUT / "feature-1024x500.png"
    canvas.save(path, "PNG")
    return path, canvas.size


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for path, size in (store_icon(), feature_graphic()):
        print(f"{str(path.relative_to(ROOT)):<44} {size[0]}x{size[1]}")


if __name__ == "__main__":
    main()
