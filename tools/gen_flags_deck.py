#!/usr/bin/env python3
"""Generate decks/geo-flags: the 50 most populous countries, one flag per card.

Unlike every other deck this one is not written by hand and not drawn by
ComfyUI, so it has its own generator instead of `make translate` / `make images`:

  label    country name          Unicode CLDR territory names
  summary  "Capital: <city>"     Wikidata labels of the capital
  info     capital + populations the table below, formatted per language
  image    the flag              Wikimedia Commons, rendered to PNG

Names come from CLDR/Wikidata rather than an LLM because they are proper nouns
with one right answer per language. Populations are deliberately NOT read from
Wikidata: P1082 on a capital mixes city, district and metro figures (New Delhi
250 thousand, Kuala Lumpur 9 million), which is what made the 2026-04
world-capitals-50 deck wrong. The table is rounded and curated by hand.

    python3 tools/gen_flags_deck.py            # text + missing flags
    python3 tools/gen_flags_deck.py --no-images
    make build                                 # → assets/decks/geo-flags.json

Stdlib only. Re-running is idempotent; existing flag PNGs are kept.
"""

import argparse
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DECK = ROOT / "decks" / "geo-flags"
STYLE = "flag"
UA = "LexifyDeckBuilder/1.0 (https://github.com/lioilsources)"
CLDR = "https://cdn.jsdelivr.net/npm/cldr-localenames-full@47.0.0/main/{loc}/territories.json"

# (ISO code, English name for comments/briefs, capital QID, country population,
#  capital population, Commons flag file). Ordered by population, mid-2024 UN
# estimates rounded to the million; capitals are city-proper figures rounded to
# two or three digits.
COUNTRIES = [
    ("in", "India", "Q987", 1_451_000_000, 16_800_000, "Flag of India.svg"),  # Delhi NCT; the NDMC district alone is 250k
    ("cn", "China", "Q956", 1_419_000_000, 21_900_000, "Flag of the People's Republic of China.svg"),
    ("us", "United States", "Q61", 345_000_000, 690_000, "Flag of the United States.svg"),
    ("id", "Indonesia", "Q3630", 283_000_000, 11_100_000, "Flag of Indonesia.svg"),
    ("pk", "Pakistan", "Q1362", 251_000_000, 1_200_000, "Flag of Pakistan.svg"),
    ("ng", "Nigeria", "Q3787", 233_000_000, 1_700_000, "Flag of Nigeria.svg"),
    ("br", "Brazil", "Q2844", 212_000_000, 2_800_000, "Flag of Brazil.svg"),
    ("bd", "Bangladesh", "Q1354", 174_000_000, 10_300_000, "Flag of Bangladesh.svg"),
    ("ru", "Russia", "Q649", 145_000_000, 13_100_000, "Flag of Russia.svg"),
    ("et", "Ethiopia", "Q3624", 132_000_000, 3_900_000, "Flag of Ethiopia.svg"),
    ("mx", "Mexico", "Q1489", 131_000_000, 9_200_000, "Flag of Mexico.svg"),
    ("jp", "Japan", "Q1490", 124_000_000, 14_200_000, "Flag of Japan.svg"),
    ("eg", "Egypt", "Q85", 117_000_000, 10_100_000, "Flag of Egypt.svg"),
    ("ph", "Philippines", "Q1461", 116_000_000, 1_850_000, "Flag of the Philippines.svg"),
    ("cd", "DR Congo", "Q3838", 109_000_000, 14_600_000, "Flag of the Democratic Republic of the Congo.svg"),
    ("vn", "Vietnam", "Q1858", 101_000_000, 8_400_000, "Flag of Vietnam.svg"),
    ("ir", "Iran", "Q3616", 92_000_000, 8_700_000, "Flag of Iran.svg"),
    ("tr", "Turkey", "Q3640", 87_000_000, 5_800_000, "Flag of Turkey.svg"),
    ("de", "Germany", "Q64", 84_000_000, 3_700_000, "Flag of Germany.svg"),
    ("th", "Thailand", "Q1861", 72_000_000, 5_500_000, "Flag of Thailand.svg"),
    ("gb", "United Kingdom", "Q84", 69_000_000, 8_900_000, "Flag of the United Kingdom.svg"),
    ("tz", "Tanzania", "Q3866", 69_000_000, 770_000, "Flag of Tanzania.svg"),
    ("fr", "France", "Q90", 68_000_000, 2_100_000, "Flag of France.svg"),
    ("za", "South Africa", "Q3926", 64_000_000, 740_000, "Flag of South Africa.svg"),  # Pretoria, the executive capital
    ("it", "Italy", "Q220", 59_000_000, 2_750_000, "Flag of Italy.svg"),
    ("ke", "Kenya", "Q3870", 56_000_000, 4_400_000, "Flag of Kenya.svg"),
    ("mm", "Myanmar", "Q37400", 54_000_000, 1_160_000, "Flag of Myanmar.svg"),
    ("co", "Colombia", "Q2841", 53_000_000, 7_700_000, "Flag of Colombia.svg"),
    ("kr", "South Korea", "Q8684", 52_000_000, 9_400_000, "Flag of South Korea.svg"),
    ("sd", "Sudan", "Q1963", 50_000_000, 5_300_000, "Flag of Sudan.svg"),
    ("ug", "Uganda", "Q3894", 50_000_000, 1_700_000, "Flag of Uganda.svg"),
    ("es", "Spain", "Q2807", 48_000_000, 3_300_000, "Flag of Spain.svg"),
    ("dz", "Algeria", "Q3561", 47_000_000, 2_400_000, "Flag of Algeria.svg"),
    ("iq", "Iraq", "Q1530", 46_000_000, 8_100_000, "Flag of Iraq.svg"),
    ("ar", "Argentina", "Q1486", 46_000_000, 3_100_000, "Flag of Argentina.svg"),
    # Commons' "Flag of Afghanistan" follows whoever holds Kabul; the card uses
    # the tricolour the UN still flies for the seat.
    ("af", "Afghanistan", "Q5838", 43_000_000, 4_600_000, "Flag of Afghanistan (2013–2021).svg"),
    ("ye", "Yemen", "Q2471", 41_000_000, 3_000_000, "Flag of Yemen.svg"),
    ("ca", "Canada", "Q1930", 40_000_000, 1_020_000, "Flag of Canada.svg"),
    ("pl", "Poland", "Q270", 38_000_000, 1_860_000, "Flag of Poland.svg"),
    ("ma", "Morocco", "Q3551", 38_000_000, 520_000, "Flag of Morocco.svg"),
    ("ao", "Angola", "Q3897", 38_000_000, 2_500_000, "Flag of Angola.svg"),
    ("ua", "Ukraine", "Q1899", 38_000_000, 2_950_000, "Flag of Ukraine.svg"),
    ("uz", "Uzbekistan", "Q269", 36_000_000, 3_000_000, "Flag of Uzbekistan.svg"),
    ("my", "Malaysia", "Q1865", 36_000_000, 2_000_000, "Flag of Malaysia.svg"),
    ("mz", "Mozambique", "Q3889", 35_000_000, 1_130_000, "Flag of Mozambique.svg"),
    ("gh", "Ghana", "Q3761", 34_000_000, 2_400_000, "Flag of Ghana.svg"),
    ("pe", "Peru", "Q2868", 34_000_000, 9_900_000, "Flag of Peru.svg"),
    ("sa", "Saudi Arabia", "Q3692", 34_000_000, 7_000_000, "Flag of Saudi Arabia.svg"),
    ("mg", "Madagascar", "Q3915", 32_000_000, 1_280_000, "Flag of Madagascar.svg"),
    ("ci", "Côte d'Ivoire", "Q3768", 32_000_000, 340_000, "Flag of Côte d'Ivoire.svg"),
]

# CLDR calls it "Congo - Kinshasa"; a flashcard wants the country's name.
COUNTRY_QID_OVERRIDE = {"cd": "Q974"}

# Wikidata labels the administrative unit ("Beijing Municipality", "Tokyo
# Metropolis"); the card wants the city's everyday name.
CAPITAL_OVERRIDE = {
    ("zh-CN", "Q956"): "北京", ("zh-CN", "Q1490"): "东京",
    ("ja", "Q956"): "北京", ("ja", "Q1490"): "東京", ("ja", "Q8684"): "ソウル",
    ("ko", "Q956"): "베이징", ("ko", "Q1490"): "도쿄", ("ko", "Q8684"): "서울",
}

# The shipped ("Gold") languages plus the en pivot — quiz-generator/internal/langs.
# Per language: CLDR locale, Wikidata label fallback chain, digit group
# separator, "label: value" joiner, then the four phrases.
NBSP = " "
LANGS = {
    "en": ("en", ["en"], ",", ": ", "Flags of the World", "Capital", "Population", "Capital population"),
    "cs": ("cs", ["cs"], NBSP, ": ", "Vlajky světa", "Hlavní město", "Počet obyvatel", "Obyvatel hlavního města"),
    "sk": ("sk", ["sk"], NBSP, ": ", "Vlajky sveta", "Hlavné mesto", "Počet obyvateľov", "Obyvateľov hlavného mesta"),
    "pl": ("pl", ["pl"], NBSP, ": ", "Flagi świata", "Stolica", "Liczba ludności", "Ludność stolicy"),
    "de": ("de", ["de"], ".", ": ", "Flaggen der Welt", "Hauptstadt", "Einwohner", "Einwohner der Hauptstadt"),
    "fr": ("fr", ["fr"], NBSP, NBSP + ": ", "Drapeaux du monde", "Capitale", "Population", "Population de la capitale"),
    "es-419": ("es-419", ["es"], ",", ": ", "Banderas del mundo", "Capital", "Población", "Población de la capital"),
    "pt-BR": ("pt", ["pt-br", "pt"], ".", ": ", "Bandeiras do mundo", "Capital", "População", "População da capital"),
    "it": ("it", ["it"], ".", ": ", "Bandiere del mondo", "Capitale", "Popolazione", "Popolazione della capitale"),
    "nl": ("nl", ["nl"], ".", ": ", "Vlaggen van de wereld", "Hoofdstad", "Inwoners", "Inwoners van de hoofdstad"),
    "da": ("da", ["da"], ".", ": ", "Verdens flag", "Hovedstad", "Indbyggere", "Indbyggere i hovedstaden"),
    "nb": ("nb", ["nb", "no"], NBSP, ": ", "Verdens flagg", "Hovedstad", "Innbyggere", "Innbyggere i hovedstaden"),
    "sv": ("sv", ["sv"], NBSP, ": ", "Världens flaggor", "Huvudstad", "Invånare", "Invånare i huvudstaden"),
    "ro": ("ro", ["ro"], ".", ": ", "Steagurile lumii", "Capitală", "Populație", "Populația capitalei"),
    "hr": ("hr", ["hr"], ".", ": ", "Zastave svijeta", "Glavni grad", "Broj stanovnika", "Stanovnika glavnog grada"),
    "sl": ("sl", ["sl"], ".", ": ", "Zastave sveta", "Glavno mesto", "Število prebivalcev", "Prebivalcev glavnega mesta"),
    "sr": ("sr", ["sr", "sr-ec"], ".", ": ", "Заставе света", "Главни град", "Број становника", "Становника главног града"),
    "bg": ("bg", ["bg"], NBSP, ": ", "Знамена на света", "Столица", "Население", "Население на столицата"),
    "ru": ("ru", ["ru"], NBSP, ": ", "Флаги мира", "Столица", "Население", "Население столицы"),
    "uk": ("uk", ["uk"], NBSP, ": ", "Прапори світу", "Столиця", "Населення", "Населення столиці"),
    "el": ("el", ["el"], ".", ": ", "Σημαίες του κόσμου", "Πρωτεύουσα", "Πληθυσμός", "Πληθυσμός πρωτεύουσας"),
    "tr": ("tr", ["tr"], ".", ": ", "Dünya bayrakları", "Başkent", "Nüfus", "Başkentin nüfusu"),
    "id": ("id", ["id"], ".", ": ", "Bendera dunia", "Ibu kota", "Jumlah penduduk", "Penduduk ibu kota"),
    "vi": ("vi", ["vi"], ".", ": ", "Quốc kỳ các nước", "Thủ đô", "Dân số", "Dân số thủ đô"),
    # Comma grouping in the RTL languages: digits joined by a comma stay one
    # bidi run, digits separated by spaces would be laid out group by group
    # from the right.
    "ar": ("ar", ["ar"], ",", ": ", "أعلام العالم", "العاصمة", "عدد السكان", "عدد سكان العاصمة"),
    "he": ("he", ["he"], ",", ": ", "דגלי העולם", "עיר הבירה", "אוכלוסייה", "אוכלוסיית הבירה"),
    "hi": ("hi", ["hi"], ",", ": ", "दुनिया के झंडे", "राजधानी", "जनसंख्या", "राजधानी की जनसंख्या"),
    "ja": ("ja", ["ja"], ",", "：", "世界の国旗", "首都", "人口", "首都の人口"),
    "ko": ("ko", ["ko"], ",", ": ", "세계의 국기", "수도", "인구", "수도 인구"),
    "zh-CN": ("zh", ["zh-cn", "zh-hans", "zh"], ",", "：", "世界国旗", "首都", "人口", "首都人口"),
}


def fetch(url, binary=False):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                data = r.read()
                return data if binary else data.decode("utf-8")
        except Exception as e:  # noqa: BLE001 — retry anything transient
            if attempt == 3:
                raise
            print(f"  retry {url[:70]}… ({e})", file=sys.stderr)
            time.sleep(2 * (attempt + 1))


def wikidata_labels(qids, wd_langs):
    """qid → {wikidata lang: label} for every requested language."""
    out = {}
    qids = sorted(set(qids))
    for i in range(0, len(qids), 40):
        url = "https://www.wikidata.org/w/api.php?" + urllib.parse.urlencode({
            "action": "wbgetentities",
            "ids": "|".join(qids[i:i + 40]),
            "props": "labels",
            "languages": "|".join(sorted(wd_langs)),
            "format": "json",
        })
        for qid, ent in json.loads(fetch(url))["entities"].items():
            out[qid] = {k: v["value"] for k, v in ent.get("labels", {}).items()}
    return out


def strip_parens(name):
    """'Myanmar (Burma)' → 'Myanmar'; CLDR's disambiguators are not names."""
    return re.sub(r"\s*[（(][^)）]*[)）]\s*$", "", name).strip()


def group(n, sep):
    s = str(n)
    parts = []
    while len(s) > 3:
        parts.insert(0, s[-3:])
        s = s[:-3]
    parts.insert(0, s)
    return sep.join(parts)


def q(s):
    """YAML double-quoted scalar (JSON string syntax is a subset of it)."""
    return json.dumps(s, ensure_ascii=False)


def write_deck_yaml():
    lines = [
        "# geo-flags — national flags of the 50 most populous countries.",
        "#",
        "# GENERATED by tools/gen_flags_deck.py — edit the table there, not this file.",
        "# Not a translation deck in the usual sense: label is the country, summary its",
        "# capital, info the populations. Images are the real flags from Wikimedia",
        "# Commons, so the only style is `flag` and nothing here goes through ComfyUI;",
        "# the briefs exist to satisfy lint, not to be rendered.",
        "slug: geo-flags",
        "version: 1",
        "tier: 0",
        f"styles:\n  - {STYLE}",
        f"default_style: {STYLE}",
        "",
        "cards:",
    ]
    for code, name, *_ in COUNTRIES:
        lines += [
            f"  - key: flag.{code}",
            f"    hint: {q('the country ' + name + ' (ISO ' + code.upper() + '), shown by its national flag')}",
            f"    image: {code}.png",
            "    brief:",
            f"      subject: {q('national flag of ' + name)}",
            "      attrs: [flat, official proportions]",
            "      setting: [plain background]",
            "      avoid: [text, flagpole]",
            "",
        ]
    (DECK / "deck.yaml").write_text("\n".join(lines), encoding="utf-8")


def write_i18n():
    wd_langs = {l for cfg in LANGS.values() for l in cfg[1]} | {"en"}
    qids = [c[2] for c in COUNTRIES] + list(COUNTRY_QID_OVERRIDE.values())
    labels = wikidata_labels(qids, wd_langs)

    def wd(qid, chain, what, lang):
        for l in chain:
            if l in labels[qid]:
                return labels[qid][l]
        print(f"  ! {lang}: no Wikidata label for {what} ({qid}), using English", file=sys.stderr)
        return labels[qid]["en"]

    (DECK / "i18n").mkdir(parents=True, exist_ok=True)
    for lang, (loc, chain, sep, colon, title, p_cap, p_pop, p_cappop) in LANGS.items():
        terr = json.loads(fetch(CLDR.format(loc=loc)))["main"][loc]["localeDisplayNames"]["territories"]
        out = [
            f"lang: {lang}",
            f"pivot: {'true' if lang == 'en' else 'false'}",
            f"title: {q(title)}",
            "cards:",
        ]
        for code, name, cap_qid, pop, cap_pop, _ in COUNTRIES:
            if code in COUNTRY_QID_OVERRIDE:
                country = wd(COUNTRY_QID_OVERRIDE[code], chain, name, lang)
            else:
                country = strip_parens(terr[code.upper()])
            capital = CAPITAL_OVERRIDE.get((lang, cap_qid)) or wd(cap_qid, chain, f"capital of {name}", lang)
            summary = f"{p_cap}{colon}{capital}"
            info = "\n".join([
                summary,
                f"{p_pop}{colon}{group(pop, sep)}",
                f"{p_cappop}{colon}{group(cap_pop, sep)}",
            ])
            out += [
                f"  flag.{code}:",
                f"    label: {q(country)}",
                f"    summary: {q(summary)}",
                f"    info: {q(info)}",
            ]
        (DECK / "i18n" / f"{lang}.yaml").write_text("\n".join(out) + "\n", encoding="utf-8")
        print(f"  i18n/{lang}.yaml")


def download_flags(width):
    out_dir = DECK / "images" / STYLE
    out_dir.mkdir(parents=True, exist_ok=True)
    for code, name, *_, commons in COUNTRIES:
        dest = out_dir / f"{code}.png"
        if dest.exists() and dest.stat().st_size > 0:
            continue
        url = ("https://commons.wikimedia.org/wiki/Special:FilePath/"
               + urllib.parse.quote(commons) + f"?width={width}")
        data = fetch(url, binary=True)
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            sys.exit(f"{name}: Commons did not return a PNG for {commons!r}")
        dest.write_bytes(data)
        print(f"  {dest.relative_to(ROOT)}  {len(data) // 1024} kB")
        time.sleep(0.5)  # be polite to the thumbnailer


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--no-images", action="store_true", help="skip the flag downloads")
    ap.add_argument("--width", type=int, default=640, help="flag render width in px")
    args = ap.parse_args()

    assert len(COUNTRIES) == 50 and len({c[0] for c in COUNTRIES}) == 50
    DECK.mkdir(parents=True, exist_ok=True)
    write_deck_yaml()
    print("deck.yaml")
    write_i18n()
    if not args.no_images:
        download_flags(args.width)


if __name__ == "__main__":
    main()
