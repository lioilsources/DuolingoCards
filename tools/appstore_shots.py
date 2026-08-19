#!/usr/bin/env python3
"""Turn raw device screenshots into App Store Connect upload sets.

Raw captures are the wrong size for the store and carry an alpha channel from
the device's rounded corners — App Store Connect rejects both. This flattens
them onto white and produces every size the app's device families require.

    python3 tools/appstore_shots.py

Input:  ../ol1n.now/apps/lexify/screenshots/raw/mobile/ios/*.png  (--src to change)
Output: store/appstore_screenshots/<size>/NN_<name>.png

Two fitting strategies, picked per target:

  cover  — the target's aspect matches the capture (both 19.5:9), so scale up
           and trim the few leftover pixels. Nothing meaningful is lost.
  frame  — iPad is 3:4 against a 19.5:9 capture; cropping to it would throw
           away most of the screen. Instead the capture is centred, at full
           height, on a pastel wash — the standard way phone content is shown
           in a tablet listing.
"""
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFilter

ROOT = pathlib.Path(__file__).resolve().parent.parent
DEFAULT_SRC = ROOT.parent / "ol1n.now/apps/lexify/screenshots/raw/mobile/ios"
OUT_DIR = ROOT / "store" / "appstore_screenshots"

# App Store Connect's required sizes. iPhone 6.9" is mandatory; iPad 13" is
# mandatory too because the Xcode target declares TARGETED_DEVICE_FAMILY "1,2".
TARGETS = {
    "iphone-6.9": ((1290, 2796), "cover"),
    "ipad-13": ((2064, 2752), "frame"),
}

# Display order in the listing — what the deck looks like before why it is
# worth buying. Anything not listed is appended alphabetically.
ORDER = ["home", "card", "card_like", "akvarel_style", "shop_languages"]

FRAME_BG = (243, 240, 248)  # pastel lavender, neutral against every deck hue


def flatten(im):
    """Drop the alpha channel; App Store Connect rejects screenshots with one."""
    if im.mode != "RGBA":
        return im.convert("RGB")
    bg = Image.new("RGB", im.size, (255, 255, 255))
    bg.paste(im, (0, 0), im)
    return bg


def cover(im, size):
    """Scale to fill [size], centre-cropping whatever overflows."""
    tw, th = size
    scale = max(tw / im.width, th / im.height)
    scaled = im.resize(
        (round(im.width * scale), round(im.height * scale)), Image.LANCZOS)
    left = (scaled.width - tw) // 2
    top = (scaled.height - th) // 2
    return scaled.crop((left, top, left + tw, top + th))


def frame(im, size):
    """Centre the capture on a pastel wash, with a rounded edge and shadow."""
    tw, th = size
    margin = round(th * 0.06)
    scale = (th - 2 * margin) / im.height
    shot = im.resize(
        (round(im.width * scale), round(im.height * scale)), Image.LANCZOS)

    radius = round(shot.width * 0.045)
    mask = Image.new("L", shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, shot.width - 1, shot.height - 1], radius=radius, fill=255)

    canvas = Image.new("RGB", size, FRAME_BG)
    pos = ((tw - shot.width) // 2, (th - shot.height) // 2)

    shadow = Image.new("RGBA", size, (0, 0, 0, 0))
    shadow.paste((15, 23, 42, 70), (pos[0], pos[1] + round(margin * 0.35)), mask)
    shadow = shadow.filter(ImageFilter.GaussianBlur(round(margin * 0.5)))
    canvas.paste(shadow, (0, 0), shadow)

    canvas.paste(shot, pos, mask)
    return canvas


def sort_key(path):
    stem = path.stem
    return (ORDER.index(stem) if stem in ORDER else len(ORDER), stem)


def main():
    argv = sys.argv[1:]
    src = DEFAULT_SRC
    if "--src" in argv:
        i = argv.index("--src")
        src = pathlib.Path(argv[i + 1])

    shots = sorted(src.glob("*.png"), key=sort_key)
    if not shots:
        raise SystemExit(f"no screenshots in {src}")

    for name, (size, mode) in TARGETS.items():
        out = OUT_DIR / name
        out.mkdir(parents=True, exist_ok=True)
        for i, path in enumerate(shots, start=1):
            im = flatten(Image.open(path))
            result = cover(im, size) if mode == "cover" else frame(im, size)
            dest = out / f"{i:02d}_{path.stem}.png"
            result.save(dest, "PNG")
            print(f"{name:<12} {size[0]}x{size[1]}  {dest.name}")


if __name__ == "__main__":
    main()
