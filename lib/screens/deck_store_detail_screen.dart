import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../l10n/app_localizations.dart';
import '../models/card_style.dart';
import '../models/language_deck.dart';
import '../services/deck_download_service.dart';
import '../services/entitlement_service.dart';
import '../services/language_deck_service.dart';
import '../utils/language_names.dart';
import '../utils/locale_direction.dart';
import '../widgets/pronounce_button.dart';
import 'language_deck_study_screen.dart';

/// Detail page for a deck in the store.
///
/// Lets the user pick source/target language and style, browse a preview of the
/// first three cards, and buy, add or open the deck.
///
/// Buying is per deck, not per (language, style): one purchase covers every
/// combination, so the picker above stays free to change afterwards.
class DeckStoreDetailScreen extends StatefulWidget {
  final LanguageDeck deck;
  final EntitlementService entitlements;

  const DeckStoreDetailScreen({
    super.key,
    required this.deck,
    required this.entitlements,
  });

  @override
  State<DeckStoreDetailScreen> createState() => _DeckStoreDetailScreenState();
}

class _DeckStoreDetailScreenState extends State<DeckStoreDetailScreen> {
  late String _l1;
  late String _l2;
  late String _style;
  int _previewIndex = 0;
  bool _purchasing = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isAvailableLocally = false;
  String? _docsPath;

  /// The learner's default L1: the device language, whatever the UI speaks.
  String get _deviceLang =>
      SchedulerBinding.instance.platformDispatcher.locale.languageCode;

  /// The language the chrome is in — deck titles in app bars and dialogs use
  /// this, not [_l1], so a screen never mixes two languages.
  String get _uiLang => Localizations.localeOf(context).languageCode;

  @override
  void initState() {
    super.initState();
    final langs = widget.deck.availableLanguages;
    _l1 = langs.contains(_deviceLang) ? _deviceLang : langs.firstOrNull ?? 'en';
    _l2 = langs.length > 1
        ? langs.firstWhere((l) => l != _l1, orElse: () => langs.first)
        : _l1;
    // Never start on a style the app cannot render: preferredStyle falls back
    // to the first style that can actually reach this device.
    _style = widget.deck.preferredStyle;
    widget.entitlements.addListener(_onEntitlementsChanged);
    _checkAvailability();
  }

  @override
  void dispose() {
    widget.entitlements.removeListener(_onEntitlementsChanged);
    super.dispose();
  }

  /// A purchase completes asynchronously through the store's purchase stream,
  /// so the confirmation arrives here rather than from [_buy]. Finish the job
  /// the user actually asked for: put the deck on the home screen and fetch it.
  void _onEntitlementsChanged() {
    if (!mounted) return;
    final owned = _ent.ownsDeck(_deck.slug, tier: _deck.tier);
    if (_purchasing && owned) {
      setState(() => _purchasing = false);
      _add(confirmed: true);
    } else {
      setState(() {});
    }
  }

  Future<void> _checkAvailability() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final slug = _deck.slug;

    // Images are "available locally" if they are in docsDir (CDN-downloaded) OR
    // fully bundled as assets (e.g. colors-basic). Probe the bundle for the latter.
    bool imagesReady =
        await DeckDownloadService.instance.isImagesDownloaded(slug, _style);
    if (!imagesReady && _deck.cards.isNotEmpty) {
      try {
        await rootBundle.load(
            'decks/$slug/images/$_style/${_deck.cards.first.image}');
        imagesReady = true;
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _isAvailableLocally = imagesReady;
        _docsPath = docsDir.path;
      });
    }
  }

  LanguageDeck get _deck => widget.deck;
  EntitlementService get _ent => widget.entitlements;

  bool get _isActivated => _ent.isActivated(_deck.slug, _l1, _l2, _style);

  /// Styles this device can actually render — see [LanguageDeck.offerableStyles].
  List<String> get _offerableStyles =>
      CardStyle.sorted(_deck.offerableStyles);

  bool get _ownsDeck => _ent.ownsDeck(_deck.slug, tier: _deck.tier);
  bool get _isFree => _ent.isFree(_deck.slug, tier: _deck.tier);

  List<LanguageCard> get _previewCards => _deck.cards.take(3).toList();

  /// Confirm the (language pair, style) selection. [buying] switches the copy:
  /// a purchase unlocks the whole deck, an add only places one combination.
  Future<bool> _confirmSelection({required bool buying}) async {
    final l10n = AppLocalizations.of(context);
    final styleMeta = CardStyle.of(_style);
    final price = _ent.priceForDeck(_deck.slug);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_deck.title(_uiLang)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConfirmRow(
              icon: Icons.translate,
              label: l10n.confirmLanguagesLabel,
              value:
                  '${langDisplayName(_l1, l10n)}  →  ${langDisplayName(_l2, l10n)}',
            ),
            const SizedBox(height: 10),
            _ConfirmRow(
              icon: styleMeta.icon,
              label: l10n.styleSectionTitle,
              value: styleMeta.label(l10n),
            ),
            const SizedBox(height: 14),
            Text(
              buying ? l10n.confirmBuyNote : l10n.confirmAddNote,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(buying
                ? (price == null ? l10n.buy : l10n.buyFor(price))
                : l10n.add),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _buy() async {
    if (!await _confirmSelection(buying: true)) return;
    if (!mounted) return;
    setState(() => _purchasing = true);
    final started = await _ent.purchaseDeck(_deck.slug);
    if (!mounted) return;
    if (!started) {
      setState(() => _purchasing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).purchaseFailedToStart)),
      );
    }
    // On success the store sheet is now up; _onEntitlementsChanged finishes.
  }

  Future<void> _add({bool confirmed = false}) async {
    // The post-purchase path arrives pre-confirmed: the user approved the
    // combination before paying, asking again would read as doubt.
    if (!confirmed && !await _confirmSelection(buying: false)) return;
    if (!mounted) return;
    final ok = await _ent.activate(
      _deck.slug, _l1, _l2, _style,
      tier: _deck.tier,
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deckNotPurchased)),
      );
    } else if (!_isAvailableLocally) {
      _startDownload();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addedToHome)),
      );
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });
    final success = await DeckDownloadService.instance.downloadDeck(
      _deck.slug,
      _style,
      onProgress: (p) {
        if (mounted) setState(() => _downloadProgress = p);
      },
    );
    if (!mounted) return;
    LanguageDeckService.instance.invalidateCache(_deck.slug);
    setState(() {
      _isDownloading = false;
      _isAvailableLocally = success;
    });
    if (success) {
      widget.entitlements.notifyDeckReady();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).downloadFailed)),
      );
    }
  }

  Future<void> _openStudyScreen() async {
    final deck = await LanguageDeckService.instance.load(_deck.slug);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LanguageDeckStudyScreen(
        deck: deck,
        l1: _l1,
        l2: _l2,
        style: _style,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langs = _deck.availableLanguages;
    final cards = _previewCards;
    final card = cards.isEmpty ? null : cards[_previewIndex % cards.length];

    return Scaffold(
      appBar: AppBar(title: Text(_deck.title(_uiLang))),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              children: [
                _LangPairPicker(
                  languages: langs,
                  l1: _l1,
                  l2: _l2,
                  onChanged: (l1, l2) => setState(() {
                    _l1 = l1;
                    _l2 = l2;
                    _previewIndex = 0;
                  }),
                ),

                if (_offerableStyles.length > 1) ...[
                  const SizedBox(height: 10),
                  _StylePicker(
                    styles: _offerableStyles,
                    selected: _style,
                    onSelected: (s) => setState(() {
                      _style = s;
                      // Availability is per (deck, style): the newly picked
                      // style may not be downloaded even though the old one was.
                      _isAvailableLocally = false;
                      _checkAvailability();
                    }),
                  ),
                ],

                const SizedBox(height: 16),

                if (card != null) ...[
                  if (cards.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _previewIndex > 0
                              ? () => setState(() => _previewIndex--)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                          label: Text(l10n.previous),
                        ),
                        Text(
                          '${_previewIndex + 1} / ${cards.length}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextButton.icon(
                          onPressed: _previewIndex < cards.length - 1
                              ? () => setState(() => _previewIndex++)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                          label: Text(l10n.next),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  _CardPreview(
                    card: card,
                    l1: _l1,
                    l2: _l2,
                    slug: _deck.slug,
                    style: _style,
                    docsPath: _docsPath,
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),
          ListenableBuilder(
            listenable: _ent,
            builder: (context, _) {
              final activatedCount = _ent.ownedEntitlements
                  .where((e) => e.deckSlug == _deck.slug)
                  .length;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _ownsDeck
                              ? Icons.check_circle_outline
                              : Icons.lock_outline,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(_ownsDeck
                            ? (_isFree ? l10n.badgeFree : l10n.badgePurchased)
                            : (_ent.priceForDeck(_deck.slug) ??
                                l10n.badgePaidDeck)),
                        const Spacer(),
                        if (activatedCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l10n.activeCount(activatedCount),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isDownloading)
                      _DownloadProgress(progress: _downloadProgress)
                    else
                      _ActionButton(
                        isOwned: _ownsDeck,
                        isFree: _isFree,
                        isActivated: _isActivated,
                        isAvailableLocally: _isAvailableLocally,
                        price: _ent.priceForDeck(_deck.slug),
                        busy: _purchasing,
                        onBuy: _buy,
                        onAdd: _add,
                        onDownload: _startDownload,
                        onOpen: _openStudyScreen,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Style picker ──────────────────────────────────────────────────────────────

/// Chips for the image styles this deck can actually deliver, with the selected
/// style's description underneath so the names mean something on first read.
class _StylePicker extends StatelessWidget {
  final List<String> styles;
  final String selected;
  final ValueChanged<String> onSelected;

  const _StylePicker({
    required this.styles,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final description = CardStyle.of(selected).description(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.styleSectionTitle, style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: styles.map((s) {
            final style = CardStyle.of(s);
            return ChoiceChip(
              avatar: Icon(
                style.icon,
                size: 18,
                color: selected == s ? theme.colorScheme.onSecondaryContainer : null,
              ),
              label: Text(style.label(l10n)),
              selected: selected == s,
              onSelected: (_) => onSelected(s),
            );
          }).toList(),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ],
    );
  }
}

// ── Card preview ──────────────────────────────────────────────────────────────

class _CardPreview extends StatelessWidget {
  final LanguageCard card;
  final String l1;
  final String l2;
  final String slug;
  final String style;
  final String? docsPath;

  const _CardPreview({
    required this.card,
    required this.l1,
    required this.l2,
    required this.slug,
    required this.style,
    this.docsPath,
  });

  @override
  Widget build(BuildContext context) {
    final foreignLabel = card.foreignLabel(l2) ?? '—';
    final foreignSummary = card.foreignSummary(l2) ?? '';
    final nativeLabel = card.nativeLabel(l1) ?? '—';
    final nativeInfo = card.nativeInfo(l1) ?? '';
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: card.image.isNotEmpty
                  ? _buildImage(card.image)
                  : _placeholder(),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DirectionalText(
                    foreignLabel,
                    lang: l2,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                PronounceButton(text: foreignLabel, lang: l2),
              ],
            ),
            if (foreignSummary.isNotEmpty) ...[
              const SizedBox(height: 4),
              DirectionalText(foreignSummary,
                  lang: l2, style: theme.textTheme.bodyMedium),
            ],

            const Divider(height: 28),

            DirectionalText(
              nativeLabel,
              lang: l1,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            if (nativeInfo.isNotEmpty) ...[
              const SizedBox(height: 4),
              DirectionalText(nativeInfo,
                  lang: l1, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  /// Load image: local docsDir (downloaded) → bundled asset (tier-0 or preview) → placeholder.
  Widget _buildImage(String image) {
    if (docsPath != null) {
      final file = File('$docsPath/decks/$slug/images/$style/$image');
      if (file.existsSync()) {
        return Image.file(file,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (_, e, st) => _placeholder());
      }
    }
    return Image.asset(
      'assets/previews/$slug/$style/$image',
      height: 180,
      fit: BoxFit.contain,
      errorBuilder: (_, e, st) => Image.asset(
        'decks/$slug/images/$style/$image',
        height: 180,
        fit: BoxFit.contain,
        errorBuilder: (_, e, st) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 180,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined,
            size: 56, color: Colors.grey.shade400),
      );
}

// ── Language pair picker ──────────────────────────────────────────────────────


class _LangPairPicker extends StatelessWidget {
  final List<String> languages;
  final String l1;
  final String l2;
  final void Function(String l1, String l2) onChanged;

  const _LangPairPicker({
    required this.languages,
    required this.l1,
    required this.l2,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Two full-width fields, caption above each. The inline sentence
    // ("I know [x] learning [y]") overflowed a 6.9" phone by ~200 px: a
    // DropdownButton sizes itself to its widest item, and seventeen language
    // names plus two captions do not fit on one line in any language. Side by
    // side they fit a Pro Max but ellipsise the longest Czech names on a 4.7"
    // phone; stacked, nothing is ever cut.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LangField(
          caption: l10n.pickerIKnow,
          value: l1,
          languages: languages,
          onChanged: (v) => onChanged(v, l2),
        ),
        const SizedBox(height: 6),
        _LangField(
          caption: l10n.pickerLearning,
          value: l2,
          languages: languages,
          onChanged: (v) => onChanged(l1, v),
        ),
      ],
    );
  }
}

class _LangField extends StatelessWidget {
  final String caption;
  final String value;
  final List<String> languages;
  final ValueChanged<String> onChanged;

  const _LangField({
    required this.caption,
    required this.value,
    required this.languages,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final safeValue =
        languages.contains(value) ? value : languages.firstOrNull ?? value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: languages
              .map((l) => DropdownMenuItem(
                    value: l,
                    child: Text(
                      langDisplayName(l, l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _DownloadProgress extends StatelessWidget {
  final double progress;
  const _DownloadProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context).downloading((progress * 100).round()),
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isOwned;
  final bool isFree;
  final bool isActivated;
  final bool isAvailableLocally;
  final String? price;
  final bool busy;
  final VoidCallback onBuy;
  final VoidCallback onAdd;
  final VoidCallback onDownload;
  final VoidCallback onOpen;

  const _ActionButton({
    required this.isOwned,
    required this.isFree,
    required this.isActivated,
    required this.isAvailableLocally,
    required this.price,
    required this.busy,
    required this.onBuy,
    required this.onAdd,
    required this.onDownload,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final price = this.price; // local copy so the null check promotes
    if (isActivated && isAvailableLocally) {
      return FilledButton.icon(
        onPressed: onOpen,
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(l10n.study),
      );
    }
    if (isActivated && !isAvailableLocally) {
      return FilledButton.icon(
        onPressed: onDownload,
        icon: const Icon(Icons.download_rounded),
        label: Text(l10n.download),
      );
    }
    if (isOwned) {
      // Free, or already bought in some other language/style pairing.
      return FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_rounded),
        label: Text(isFree ? l10n.addFree : l10n.add),
      );
    }
    return FilledButton.tonal(
      onPressed: busy ? null : onBuy,
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          // Without store metadata there is no honest price to show, so the
          // button says what it does and lets the store sheet name the amount.
          : Text(price == null ? l10n.buy : l10n.buyFor(price)),
    );
  }
}


class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 10),
        // Expanded so a long value ("Indonesian → Vietnamese" with flags)
        // wraps inside the dialog instead of overflowing it.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text(value,
                  softWrap: true,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
