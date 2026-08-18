#!/usr/bin/env python3
"""Render the App Store Connect review screenshot for each paid deck.

Every in-app purchase needs a screenshot that shows App Review what is being
sold. Ours is a fan of three cards from the deck: the leading three cards of
the bundled preview set, in the deck's illustrated style, laid out the way the
app stacks them.

    python3 tools/iap_review_shot.py            # every paid deck
    python3 tools/iap_review_shot.py animals-sea

Output: store/review_screenshots/<slug>.png at 1242x1656 (App Store Connect
requires at least 640x920).
"""
import json
import pathlib
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "store" / "review_screenshots"

W, H = 1242, 1656
BG_TOP = (247, 249, 252)
BG_BOTTOM = (226, 233, 243)
INK = (24, 32, 46)
MUTED = (108, 122, 143)

CARD_W = 480
PAD = 22
# Back-to-front: the middle card lands on top of the two behind it.
#
# (angle, dx, dy). Rotation alone had the middle card hiding almost all of the
# other two, so the wings also step outward and the middle one drops — that is
# what lets all three subjects show at once. The dx values are capped by the
# canvas width, not chosen for looks: past ~215px the rotated top corner of a
# wing card runs off the edge.
FAN = [(-12, -215, -22), (12, 215, -22), (0, 0, 44)]
# The fan pivots about each card's bottom centre, the way a hand of cards
# splays: tops spread apart, bottoms stay together.
HEADER_BOTTOM = 350

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


def rounded_card(img, label, sub):
    """One card: square image, label, two lines of summary.

    Height follows the content — a fixed height left the fan's top card half
    empty, which reads as a rendering bug rather than a card.
    """
    side = CARD_W - 2 * PAD
    probe = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    body = font(FONT_TEXT, 24, 400)
    lines = wrap(probe, sub, body, side)

    label_y = PAD + side + 32
    body_y = label_y + 58
    height = body_y + len(lines) * 32 + PAD + 10

    card = Image.new("RGBA", (CARD_W, height), (255, 255, 255, 255))
    draw = ImageDraw.Draw(card)

    photo = img.convert("RGB").resize((side, side), Image.LANCZOS)
    mask = Image.new("L", (side, side), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, side, side], radius=20, fill=255)
    card.paste(photo, (PAD, PAD), mask)

    draw.text((PAD, label_y), label, font=font(FONT_BOLD, 40, 700), fill=INK)
    for i, line in enumerate(lines):
        draw.text((PAD, body_y + i * 32), line, font=body, fill=MUTED)

    rounded = Image.new("RGBA", (CARD_W, height), (0, 0, 0, 0))
    m = Image.new("L", (CARD_W, height), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, CARD_W - 1, height - 1], radius=32, fill=255)
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


def background():
    bg = Image.new("RGB", (W, H), BG_TOP)
    draw = ImageDraw.Draw(bg)
    for y in range(H):
        t = y / H
        draw.line(
            [(0, y), (W, y)],
            fill=tuple(int(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM)),
        )
    return bg


def render(slug, deck, style, lang="en"):
    cards = deck["cards"][:3]
    if len(cards) < 3:
        raise SystemExit(f"{slug}: needs 3 cards, has {len(cards)}")

    img_dir = ROOT / "assets" / "previews" / slug / style
    canvas = background()
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))

    art = [
        rounded_card(
            Image.open(img_dir / c["image"]),
            c["label"].get(lang, c["key"]),
            c["summary"].get(lang, ""),
        )
        for c in cards
    ]
    for c in cards:
        if not (img_dir / c["image"]).exists():
            raise SystemExit(f"missing preview image: {img_dir / c['image']}")

    # Lay the fan out around a nominal pivot, then measure what was actually
    # drawn and recentre it. Predicting the extent is not worth it: rotation,
    # the per-card dy and the blurred shadow all move the real bounds.
    pivot = (W // 2, (HEADER_BOTTOM + H) // 2 + max(a.height for a in art) // 2)

    for (angle, dx, dy), a in zip(FAN, art):
        rot = pivoted(a, angle)
        pos = (pivot[0] + dx - rot.width // 2, pivot[1] + dy - rot.height // 2)
        layer.alpha_composite(shadow_of(rot), (pos[0], pos[1] + 16))
        layer.alpha_composite(rot, pos)

    bbox = layer.getbbox()
    if bbox:
        shift = (HEADER_BOTTOM + H) // 2 - (bbox[1] + bbox[3]) // 2
        layer = ImageChops.offset(layer, 0, shift)

    canvas.paste(layer, (0, 0), layer)

    draw = ImageDraw.Draw(canvas)
    title = deck["titles"].get(lang, slug)
    tf = font(FONT_BOLD, 82, 700)
    draw.text(((W - draw.textlength(title, font=tf)) / 2, 150), title, font=tf, fill=INK)

    sf = font(FONT_TEXT, 36, 400)
    sub = f"{len(deck['cards'])} cards · {len(deck['titles'])} languages · {style}"
    draw.text(((W - draw.textlength(sub, font=sf)) / 2, 268), sub, font=sf, fill=MUTED)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out = OUT_DIR / f"{slug}.png"
    canvas.save(out, "PNG")
    return out


def main():
    catalog = json.loads((ROOT / "assets" / "catalog.json").read_text())
    paid = [p["unlocks"][0] for p in catalog["products"]]
    wanted = sys.argv[1:] or paid

    for slug in wanted:
        deck = json.loads((ROOT / "assets" / "decks" / f"{slug}.json").read_text())
        # The illustrated style is the one that distinguishes the deck visually;
        # photo is the base every deck shares.
        style = next((s for s in deck["styles"] if s != "photo"), deck["styles"][0])
        out = render(slug, deck, style)
        print(f"{slug:<17} {style:<11} -> {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
