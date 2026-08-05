CONTENT   := quiz-generator/bin/content
DECKS_SRC := decks
DECKS_OUT := assets/decks
SPARK_LLM := http://192.168.88.66:8080
SPARK_IMG := http://192.168.88.66:8188
WORKERS   ?= 5

# Models for the restyle passes (names as they appear in ComfyUI's model folders).
PONY_CKPT  ?=
ILLU_CKPT  ?=
CONTROLNET ?=

# Models for the iterative image-tuning loop (OpenAI-compatible on $(SPARK_LLM)).
VALIDATOR_MODEL := validator  # vision model that scores generated images
BUILDER_MODEL   := builder    # instruct model that rewrites prompts
TUNE_ITERS      := 4
TUNE_SCORE      := 8

# ── build tool ───────────────────────────────────────────────────────────────

.PHONY: build-tool
build-tool:
	cd quiz-generator && go build -o bin/content ./cmd/content

$(CONTENT): build-tool

# ── lint / build assets ───────────────────────────────────────────────────────

.PHONY: lint
lint: $(CONTENT)
	$(CONTENT) lint -decks $(DECKS_SRC)

.PHONY: lint-strict
lint-strict: $(CONTENT)
	$(CONTENT) lint -decks $(DECKS_SRC) -strict -images

.PHONY: build
build: $(CONTENT)
	$(CONTENT) build -decks $(DECKS_SRC) -out $(DECKS_OUT)

# ── translations ──────────────────────────────────────────────────────────────
# Translate all missing languages for all decks (or pass DECK=animals-sea).

.PHONY: translate
translate: $(CONTENT)
	$(CONTENT) translate -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  -url $(SPARK_LLM) -workers $(WORKERS)

.PHONY: translate-force
translate-force: $(CONTENT)
	$(CONTENT) translate -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  -url $(SPARK_LLM) -workers $(WORKERS) -force

# ── images ────────────────────────────────────────────────────────────────────
# Generate missing images for all decks (or pass DECK=animals-sea STYLE=pony-cartoon).
#
# RESTYLE_FLAGS are only read by the img2img restyle styles (pony-* / illustrious-*);
# text-to-image styles ignore them, so they can be passed to every images run.

RESTYLE_FLAGS = $(if $(PONY_CKPT),-pony-checkpoint $(PONY_CKPT)) \
                $(if $(ILLU_CKPT),-illustrious-checkpoint $(ILLU_CKPT)) \
                $(if $(CONTROLNET),-controlnet $(CONTROLNET)) \
                $(if $(DENOISE),-denoise $(DENOISE)) \
                $(if $(CONTROL_STRENGTH),-control-strength $(CONTROL_STRENGTH))

.PHONY: images
images: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  $(if $(STYLE),-style $(STYLE)) \
	  -url $(SPARK_IMG) -workers 2 $(RESTYLE_FLAGS) $(if $(FORCE),-force)

.PHONY: images-force
images-force: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  $(if $(STYLE),-style $(STYLE)) \
	  -url $(SPARK_IMG) -workers 2 $(RESTYLE_FLAGS) -force

# ── restyle: flux base → Pony watercolor / oil (img2img) ──────────────────────
# Repaints each card's flux-real image through Pony SDXL in a paint medium,
# preserving the composition (ComfyUI img2img: LoadImage → VAEEncode → KSampler).
# Inspired by Kiran's flux2pony pass. The flux-real base images must exist first:
#   make images DECK=animals-sea STYLE=flux-real
# Then, writing to images/pony-watercolor/ and images/pony-oil/:
#   make watercolor DECK=animals-sea
#   make oil        DECK=animals-sea
# Pass FORCE=1 to overwrite existing output. The Pony checkpoint defaults inside
# the tool; override with PONY_CKPT=<name>. Tune the style-vs-subject balance with
# DENOISE=<0..1> (higher = freer repaint, more style; lower = closer to the base).
# For a structure-locked repaint that survives a much higher denoise, see the
# Illustrious ControlNet targets below.

.PHONY: watercolor
watercolor: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  -style pony-watercolor -url $(SPARK_IMG) -workers 2 \
	  $(RESTYLE_FLAGS) $(if $(FORCE),-force)

.PHONY: oil
oil: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  -style pony-oil -url $(SPARK_IMG) -workers 2 \
	  $(RESTYLE_FLAGS) $(if $(FORCE),-force)

# ── restyle: flux base → Illustrious art styles (ControlNet img2img) ──────────
# Illustrious knows far more art styles than Pony but far fewer real-world
# objects — it cannot draw an ant. So it never generates from text: it repaints
# the flux-real base, with a Canny ControlNet pinning the subject's shape
# (LoadImage → Canny → ControlNetApplyAdvanced → KSampler). The structure lock is
# what lets denoise run at 0.75-0.85 so the style actually takes; plain img2img
# would dissolve the subject first. The flux-real base must exist:
#   make images DECK=animals-insects STYLE=flux-real
# Then, writing to images/illustrious-<style>/:
#   make anime     DECK=animals-insects
#   make storybook DECK=animals-insects
#   make flat      DECK=animals-insects
#   make ukiyoe    DECK=animals-insects
# FORCE=1 overwrites. Pick models with ILLU_CKPT=<name> CONTROLNET=<name>.
# Balance style vs. subject with DENOISE=<0..1> (higher = more style) and
# CONTROL_STRENGTH=<0..1+> (higher = stricter adherence to the base anatomy).

.PHONY: anime
anime: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  -style illustrious-anime -url $(SPARK_IMG) -workers 2 \
	  $(RESTYLE_FLAGS) $(if $(FORCE),-force)

.PHONY: storybook
storybook: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  -style illustrious-storybook -url $(SPARK_IMG) -workers 2 \
	  $(RESTYLE_FLAGS) $(if $(FORCE),-force)

.PHONY: flat
flat: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  -style illustrious-flat -url $(SPARK_IMG) -workers 2 \
	  $(RESTYLE_FLAGS) $(if $(FORCE),-force)

.PHONY: ukiyoe
ukiyoe: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  -style illustrious-ukiyoe -url $(SPARK_IMG) -workers 2 \
	  $(RESTYLE_FLAGS) $(if $(FORCE),-force)

# ── tune (iterative image tuning) ──────────────────────────────────────────────
# Generate → validate (VL model) → refine prompt (instruct model) → loop, per card.
# Saves the final image, the winning prompt (decks/<slug>/tuned/<style>.yaml) and a
# transcript of the LLM conversation (decks/<slug>/tuned/logs/).
# Usage: make tune DECK=animals-sea STYLE=pony-cartoon

.PHONY: tune
tune: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  $(if $(STYLE),-style $(STYLE)) \
	  -url $(SPARK_IMG) -workers 2 -force \
	  -tune -max-iters $(TUNE_ITERS) -score-threshold $(TUNE_SCORE) \
	  -llm-url $(SPARK_LLM) \
	  -validator-model $(VALIDATOR_MODEL) -builder-model $(BUILDER_MODEL)

# ── prompts (debug) ───────────────────────────────────────────────────────────

.PHONY: prompts
prompts: $(CONTENT)
	$(CONTENT) prompts -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  $(if $(STYLE),-style $(STYLE))

# ── full pipeline for a new deck ─────────────────────────────────────────────
# Usage: make new-deck DECK=animals-sea STYLE=pony-cartoon

.PHONY: new-deck
new-deck: translate images build
	@echo "done: $(DECK) translated + images generated + assets built"

# ── flutter ───────────────────────────────────────────────────────────────────

.PHONY: run
run: build
	flutter run

.PHONY: run-macos
run-macos: build
	flutter run -d macos

.PHONY: analyze
analyze:
	flutter analyze
