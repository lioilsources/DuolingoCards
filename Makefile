CONTENT   := quiz-generator/bin/content
DECKS_SRC := decks
DECKS_OUT := assets/decks
SPARK_LLM := http://192.168.88.66:8080
SPARK_IMG := http://192.168.88.66:8188
WORKERS   ?= 5

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

.PHONY: images
images: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  $(if $(STYLE),-style $(STYLE)) \
	  -url $(SPARK_IMG) -workers 2

.PHONY: images-force
images-force: $(CONTENT)
	$(CONTENT) images -decks $(DECKS_SRC) $(if $(DECK),-deck $(DECK)) \
	  $(if $(STYLE),-style $(STYLE)) \
	  -url $(SPARK_IMG) -workers 2 -force

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
