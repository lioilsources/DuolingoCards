#!/usr/bin/env python3
"""Render the App Store product page header and search results artwork.

    python3 tools/store_header.py

  store/appstore_creative/header-3840x1646.png   product page header (21:9)
  store/appstore_creative/search-3840x2560.png   search results asset (3:2)

Both are a table strewn with the app's own cards — picture above, word below,
each word in a different language — because that is the product. Nothing but
the card labels is text, so one image serves every localization.

Apple publishes the sizes but not how each device crops them. The header
template marks a 1646x661 "Art Safe Area" in the centre of the 3840x1646
canvas; the three hero cards sit inside it and the rest of the wall may be cut
anywhere. Check the result with Preview in App Store Connect before submitting.
"""
import glob
import json
import os
import pathlib
import random

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
DECKS = ROOT / "docs" / "decks"
OUT = ROOT / "store" / "appstore_creative"

# cute_kid_fonts is a pub git dependency; its checkout carries the TTFs.
FONTS = glob.glob(os.path.expanduser(
    "~/.pub-cache/git/CuteKidFonts-*/fonts/DynaPuff-Variable.ttf"))

INK = (33, 33, 40)
# The deck tiles' mint, lavender and rose.
BG = [(226, 242, 232), (240, 236, 248), (251, 232, 232)]

# (deck, style, card key, label language). Latin-script languages only:
# DynaPuff has no Cyrillic, Greek, Arabic or CJK. The first three are the
# heroes in the safe area; the rest fill the wall in order, row by row.
HEROES = [
    ("geo-flags", "flag", "flag.br", "pt-BR"),
    ("animals-pets", "photo", "pet.hamster", "en"),
    ("animals-birds", "pastel", "animal.flamingo", "es-419"),
]
WALL = [
    ("food-fruits", "pastel", "fruit.strawberry", "fr"),
    ("geo-flags", "flag", "flag.jp", "de"),
    ("animals-wild", "photo", "animal.giraffe", "cs"),
    ("weather", "watercolor", "weather.rainbow", "es-419"),
    ("animals-sea", "pastel", "animal.octopus", "fr"),
    ("geo-flags", "flag", "flag.mx", "en"),
    ("animals-pets", "ink", "pet.rabbit", "fr"),
    ("food-fruits", "photo", "fruit.pineapple", "id"),
    ("animals-birds", "photo", "animal.toucan", "de"),
    ("geo-flags", "flag", "flag.in", "es-419"),
    ("animals-wild", "pastel", "animal.koala", "pt-BR"),
    ("weather", "watercolor", "weather.sunny", "cs"),
    ("animals-sea", "photo", "animal.clownfish", "en"),
    ("geo-flags", "flag", "flag.de", "fr"),
    ("animals-pets", "photo", "pet.dog", "cs"),
    ("food-fruits", "pastel", "fruit.lemon", "tr"),
    ("animals-birds", "pastel", "animal.owl", "id"),
    ("geo-flags", "flag", "flag.us", "pt-BR"),
    ("animals-wild", "photo", "animal.elephant", "es-419"),
    ("animals-sea", "pastel", "animal.sea_turtle", "de"),
    ("weather", "watercolor", "weather.snowy", "en"),
    ("geo-flags", "flag", "flag.ng", "fr"),
    ("animals-pets", "ink", "pet.cat", "es-419"),
    ("food-fruits", "photo", "fruit.watermelon", "cs"),
    ("animals-birds", "photo", "animal.penguin", "pt-BR"),
    ("geo-flags", "flag", "flag.id", "id"),
    ("animals-wild", "pastel", "animal.lion", "tr"),
    ("animals-sea", "photo", "animal.dolphin", "fr"),
    ("geo-flags", "flag", "flag.eg", "de"),
    ("animals-pets", "photo", "pet.parrot", "en"),
    ("food-fruits", "pastel", "fruit.cherry", "es-419"),
    ("animals-birds", "pastel", "animal.peacock", "cs"),
    ("geo-flags", "flag", "flag.ph", "pt-BR"),
    ("animals-wild", "photo", "animal.zebra", "id"),
    ("weather", "watercolor", "weather.cloudy", "tr"),
    ("animals-sea", "pastel", "animal.starfish", "en"),
    ("geo-flags", "flag", "flag.et", "fr"),
    ("animals-pets", "ink", "pet.turtle", "de"),
    ("food-fruits", "photo", "fruit.orange", "es-419"),
    ("animals-birds", "photo", "animal.swan", "cs"),
]

_decks = {}


def card_art(slug, style, key, lang):
    if slug not in _decks:
        _decks[slug] = json.loads((DECKS / slug / "deck.json").read_text())
    card = next(c for c in _decks[slug]["cards"] if c["key"] == key)
    image = Image.open(DECKS / slug / "images" / style / card["image"])
    return image.convert("RGB"), card["label"][lang]


def font(size):
    f = ImageFont.truetype(FONTS[0], size)
    f.set_variation_by_axes([600])
    return f


def card(spec, w):
    """One card, RGBA: picture on a white tile, the word underneath."""
    art, label = card_art(*spec)
    pad = round(w * 0.06)
    side = w - 2 * pad
    h = round(w * 1.24)
    tile = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(tile)
    draw.rounded_rectangle([0, 0, w - 1, h - 1], radius=round(w * 0.08),
                           fill=(255, 255, 255, 255))

    # Square art fills the window; a flag keeps its shape, centred in it.
    scale = side / max(art.size)
    art = art.resize((round(art.width * scale), round(art.height * scale)),
                     Image.LANCZOS)
    mask = Image.new("L", art.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, art.width - 1, art.height - 1], radius=round(w * 0.04), fill=255)
    at = (pad + (side - art.width) // 2, pad + (side - art.height) // 2)
    tile.paste(art, at, mask)
    # A hairline, or a flag with a white band (Indonesia, Japan) loses its
    # edge against the white tile.
    draw.rounded_rectangle(
        [at[0], at[1], at[0] + art.width - 1, at[1] + art.height - 1],
        radius=round(w * 0.04), outline=(0, 0, 0, 38), width=max(2, w // 200))

    size = round(w * 0.105)
    while size > 10 and font(size).getlength(label) > side:
        size -= 2
    band = h - (pad + side)
    draw.text((w / 2, pad + side + band / 2 - w * 0.01), label, font=font(size),
              fill=INK, anchor="mm")
    return tile


def place(canvas, tile, centre, angle):
    tile = tile.rotate(angle, resample=Image.BICUBIC, expand=True)
    x = round(centre[0] - tile.width / 2)
    y = round(centre[1] - tile.height / 2)
    blur = round(tile.width * 0.03)
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow.paste((40, 30, 60, 80), (x, y + blur), tile.getchannel("A"))
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(tile, (x, y))


def background(size):
    w, h = size
    strip = Image.new("RGB", (len(BG), 1))
    strip.putdata(BG)
    return strip.resize((w, h), Image.BICUBIC).convert("RGBA")


def render(size, card_w, name):
    w, h = size
    rng = random.Random(7)
    canvas = background(size)
    card_h = round(card_w * 1.24)
    step_x = round(card_w * 1.06)
    step_y = round(card_h * 1.08)

    # A brick-laid wall centred on the canvas, so the middle row's middle
    # three cards land in the centre whatever the size.
    rows = h // step_y // 2 + 1
    cols = w // step_x // 2 + 2
    slots = []
    for r in range(-rows, rows + 1):
        shift = step_x / 2 if r % 2 else 0
        for c in range(-cols, cols + 1):
            slots.append((r, c, (w / 2 + c * step_x + shift, h / 2 + r * step_y)))

    wall = iter(WALL * 4)
    heroes = {(0, -1): HEROES[0], (0, 0): HEROES[1], (0, 1): HEROES[2]}
    for r, c, centre in slots:
        if (r, c) in heroes:
            continue
        jitter = (rng.uniform(-0.03, 0.03) * card_w,
                  rng.uniform(-0.03, 0.03) * card_w)
        place(canvas, card(next(wall), card_w),
              (centre[0] + jitter[0], centre[1] + jitter[1]),
              rng.uniform(-5, 5))
    # Heroes last, a touch larger, so they sit on top of their neighbours.
    for (r, c), spec in heroes.items():
        centre = next(p for rr, cc, p in slots if (rr, cc) == (r, c))
        place(canvas, card(spec, round(card_w * 1.08)), centre, -3 * c)

    OUT.mkdir(parents=True, exist_ok=True)
    dest = OUT / name
    canvas.convert("RGB").save(dest, "PNG")
    print(f"{size[0]}x{size[1]}  {dest.relative_to(ROOT)}")


def main():
    if not FONTS:
        raise SystemExit("DynaPuff not found — run `flutter pub get` first")
    # 3 x 500 = 1500 wide, 620 tall: the hero trio inside the 1646x661 safe area.
    render((3840, 1646), 460, "header-3840x1646.png")
    render((3840, 2560), 560, "search-3840x2560.png")


if __name__ == "__main__":
    main()
