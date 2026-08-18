#!/usr/bin/env python3
"""Render the App Store Connect review screenshot for each paid deck.

Every in-app purchase needs a screenshot that shows App Review what is being
sold. Ours is a fan of three cards from the deck: the leading three cards of
the bundled preview set, in the deck's illustrated style, laid out the way the
app stacks them.

    python3 tools/iap_review_shot.py                    # every paid deck
    python3 tools/iap_review_shot.py animals-sea
    python3 tools/iap_review_shot.py --size 640x920    # other canvas

Output: store/review_screenshots/<slug>.png.

The default is 1242x2208, a canonical App Store screenshot size (5.5" iPhone).
App Store Connect documents a 640x920 minimum for the in-app purchase review
screenshot but rejects some sizes that clear it, so a size it already knows is
the safer default; --size covers the rest.

The card size adapts to the canvas: the fan is laid out at the largest width
that still clears the canvas edge, measured rather than assumed.
"""
import json
import pathlib
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "store" / "review_screenshots"

W, H = 1242, 2208  # overridden by --size
BG_TOP = (247, 249, 252)
BG_BOTTOM = (226, 233, 243)
INK = (24, 32, 46)
MUTED = (108, 122, 143)

MARGIN = 40  # smallest gap the fan may leave at the canvas edge
# Back-to-front: the middle card lands on top of the two behind it.
#
# (angle, dx, dy) with the offsets as fractions of card width. Rotation alone
# had the middle card hiding almost all of the other two, so the wings also step
# outward and the middle one drops — that is what lets all three subjects show
# at once.
FAN = [(-12, -0.45, -0.046), (12, 0.45, -0.046), (0, 0, 0.092)]
# The fan pivots about each card's bottom centre, the way a hand of cards
# splays: tops spread apart, bottoms stay together.
def HEADER_BOTTOM(h):
    return round(350 * h / 2208)

FONT_BOLD = "/System/Library/Fonts/SFNS.ttf"
FONT_TEXT = "/System/Library/Fonts/SFNS.ttf"


def font(path, size, weight=None):
    f = ImageFont.truetype(path, size)
    if weight is not None:
        try:
            f.set_variation_by_axes([weight])
        except Exception:
            pass  # Static fallback: the face just stays at its default weight.
    return f


def wrap(draw, text, f, width):
    lines, line = [], ""
    for word in text.split():
        probe = f"{line} {word}".strip()
        if line and draw.textlength(probe, font=f) > width:
            lines.append(line)
            line = word
        else:
            line = probe
    if line:
        lines.append(line)
    if len(lines) > 3:
        # Cutting mid-sentence reads as a bug; an ellipsis reads as a summary.
        lines = lines[:3]
        lines[-1] = lines[-1].rstrip(" ,.") + "…"
    return lines


def rounded_card(img, label, sub, card_w):
    """One card: square image, label, up to three lines of summary.

    Height follows the content — a fixed height left the fan's top card half
    empty, which reads as a rendering bug rather than a card. Every metric is
    proportional to card_w so the same layout survives a change of canvas.
    """
    k = card_w / 480  # 480 is the width these numbers were tuned at
    pad = round(22 * k)
    side = card_w - 2 * pad
    probe = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    body = font(FONT_TEXT, round(24 * k), 400)
    lines = wrap(probe, sub, body, side)

    label_y = pad + side + round(32 * k)
    body_y = label_y + round(58 * k)
    step = round(32 * k)
    height = body_y + len(lines) * step + pad + round(10 * k)

    card = Image.new("RGBA", (card_w, height), (255, 255, 255, 255))
    draw = ImageDraw.Draw(card)

    photo = img.convert("RGB").resize((side, side), Image.LANCZOS)
    mask = Image.new("L", (side, side), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, side, side], radius=round(20 * k), fill=255)
    card.paste(photo, (pad, pad), mask)

    draw.text((pad, label_y), label, font=font(FONT_BOLD, round(40 * k), 700), fill=INK)
    for i, line in enumerate(lines):
        draw.text((pad, body_y + i * step), line, font=body, fill=MUTED)

    rounded = Image.new("RGBA", (card_w, height), (0, 0, 0, 0))
    m = Image.new("L", (card_w, height), 0)
    ImageDraw.Draw(m).rounded_rectangle(
        [0, 0, card_w - 1, height - 1], radius=round(32 * k), fill=255)
    rounded.paste(card, (0, 0), m)
    return rounded


def pivoted(card, angle):
    """Rotate about the card's bottom centre, returned on a square canvas whose
    own centre is that pivot — so callers just drop it on the fan point."""
    r = 2 * (card.width + card.height)
    canvas = Image.new("RGBA", (r, r), (0, 0, 0, 0))
    canvas.alpha_composite(card, (r // 2 - card.width // 2, r // 2 - card.height))
    return canvas.rotate(angle, resample=Image.BICUBIC, center=(r // 2, r // 2))


def shadow_of(layer, blur=22):
    from PIL import ImageFilter

    shadow = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    shadow.paste((15, 23, 42, 60), (0, 0), layer.split()[3])
    return shadow.filter(ImageFilter.GaussianBlur(blur))


def background(size):
    w, h = size
    bg = Image.new("RGB", size, BG_TOP)
    draw = ImageDraw.Draw(bg)
    for y in range(h):
        t = y / h
        draw.line(
            [(0, y), (w, y)],
            fill=tuple(int(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM)),
        )
    return bg


def fan_layer(cards, img_dir, lang, card_w, size):
    """Compose the fan on a transparent layer and report its bounding box."""
    w, h = size
    art = [
        rounded_card(
            Image.open(img_dir / c["image"]),
            c["label"].get(lang, c["key"]),
            c["summary"].get(lang, ""),
            card_w,
        )
        for c in cards
    ]
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    pivot_y = (HEADER_BOTTOM(h) + h) // 2 + max(a.height for a in art) // 2

    for (angle, fx, fy), a in zip(FAN, art):
        rot = pivoted(a, angle)
        pos = (
            w // 2 + round(fx * card_w) - rot.width // 2,
            pivot_y + round(fy * card_w) - rot.height // 2,
        )
        layer.alpha_composite(shadow_of(rot, blur=max(8, round(22 * card_w / 480))),
                              (pos[0], pos[1] + round(16 * card_w / 480)))
        layer.alpha_composite(rot, pos)
    return layer, layer.getbbox()


def render(slug, deck, style, size, lang="en"):
    cards = deck["cards"][:3]
    if len(cards) < 3:
        raise SystemExit(f"{slug}: needs 3 cards, has {len(cards)}")

    w, h = size
    img_dir = ROOT / "assets" / "previews" / slug / style
    for c in cards:
        if not (img_dir / c["image"]).exists():
            raise SystemExit(f"missing preview image: {img_dir / c['image']}")

    # Try progressively narrower cards until the fan clears the canvas edge.
    # Measuring beats predicting: rotation, the per-card offsets and the blurred
    # shadow all move the real bounds, and the binding limit flips between the
    # canvas width and its height depending on the size asked for.
    target = min(round(w * 0.52), round((h - HEADER_BOTTOM(h)) * 0.42))
    layer = bbox = None
    for card_w in range(target, 200, -16):
        layer, bbox = fan_layer(cards, img_dir, lang, card_w, size)
        if bbox and bbox[0] >= MARGIN and bbox[2] <= w - MARGIN and \
           (bbox[3] - bbox[1]) <= h - HEADER_BOTTOM(h) - MARGIN:
            break
    if layer is None or bbox is None:
        raise SystemExit(f"{slug}: cannot fit the fan into {w}x{h}")

    canvas = background(size)
    shift = (HEADER_BOTTOM(h) + h) // 2 - (bbox[1] + bbox[3]) // 2
    layer = ImageChops.offset(layer, 0, shift)
    canvas.paste(layer, (0, 0), layer)

    draw = ImageDraw.Draw(canvas)
    k = w / 1242
    title = deck["titles"].get(lang, slug)
    tf = font(FONT_BOLD, round(82 * k), 700)
    draw.text(((w - draw.textlength(title, font=tf)) / 2, round(150 * k)),
              title, font=tf, fill=INK)

    sf = font(FONT_TEXT, round(36 * k), 400)
    sub = f"{len(deck['cards'])} cards · {len(deck['titles'])} languages · {style}"
    draw.text(((w - draw.textlength(sub, font=sf)) / 2, round(268 * k)),
              sub, font=sf, fill=MUTED)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out = OUT_DIR / f"{slug}.png"
    canvas.save(out, "PNG")
    return out


def main():
    argv = sys.argv[1:]
    size = (W, H)
    if "--size" in argv:
        i = argv.index("--size")
        w, _, h = argv[i + 1].partition("x")
        size = (int(w), int(h))
        del argv[i:i + 2]

    catalog = json.loads((ROOT / "assets" / "catalog.json").read_text())
    paid = [p["unlocks"][0] for p in catalog["products"]]

    for slug in argv or paid:
        deck = json.loads((ROOT / "assets" / "decks" / f"{slug}.json").read_text())
        # The illustrated style is the one that distinguishes the deck visually;
        # photo is the base every deck shares.
        style = next((s for s in deck["styles"] if s != "photo"), deck["styles"][0])
        out = render(slug, deck, style, size)
        print(f"{slug:<17} {style:<11} {size[0]}x{size[1]} -> {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
