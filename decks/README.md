# Authoring decks (no-backend pipeline)

Each deck is one folder, versioned in Git. There is **no database and no runtime
server** — `lint` replaces DB constraints and `build` produces the bundled
`deck.json` the app ships.

## Layout

```
decks/<slug>/
  deck.yaml            # language-neutral spine
  i18n/<lang>.yaml     # display text per language (cs is the fact-check pivot)
  images/<style>/*.webp # generated images (binaries; keep out of the text repo / use git-lfs)
```

### deck.yaml

The spine carries **no display text** — only stable keys, translator hints, image
filenames, and a language-neutral *visual brief* per card:

```yaml
slug: animals-wild
version: 1
tier: 0
styles: [flux-real]
default_style: flux-real
cards:
  - key: animal.lion
    hint: the big cat, not the star sign
    image: animal.lion.webp
    brief: { subject: lion, attrs: [sitting, calm], setting: savanna grass, avoid: [text, blood] }
```

### i18n/<lang>.yaml

Three learning fields per concept. `summary` shows on the **foreign** side,
`info` on the **native** side:

```yaml
lang: cs
pivot: true            # the one fact-checked source language
title: Divoká zvířata
cards:
  animal.lion:
    label: lev
    summary: Velká kočkovitá šelma z Afriky.
    info: |
      Lev je velká kočkovitá šelma žijící v afrických savanách...
```

**Author `info`/`summary` in the cs pivot, fact-check it, then translate** to the
other 19 target languages (`quiz-generator/internal/langs`). `label` is
translated independently (single word, disambiguated by `hint`).

## Commands

Build the tool once, then run from the repo root:

```bash
(cd quiz-generator && go build -o /tmp/content ./cmd/content)

/tmp/content lint  -decks decks            # validate; -strict requires all 20 languages
/tmp/content build -decks decks -out assets/decks   # → assets/decks/<slug>.json (bundled by the app)
/tmp/content prompts -decks decks -deck animals-wild -style pony-cartoon
```

`build` runs lint first and refuses decks with errors. The output `deck.json`
folds every language into per-field maps and is committed under `assets/decks/`
so it ships in the app binary (distribution variant B).
