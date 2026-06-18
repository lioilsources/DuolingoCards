import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/language_deck.dart';
import '../services/entitlement_service.dart';
import '../utils/locale_direction.dart';
import '../widgets/credit_pack_sheet.dart';
import '../widgets/pronounce_button.dart';

/// Detail page for a deck in the store.
///
/// Lets the user pick source/target language and style, browse a preview of the
/// first three cards, and unlock or open the deck.
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
  int _previewIndex = 0; // 0–2
  bool _unlocking = false;

  String get _deviceLang =>
      SchedulerBinding.instance.platformDispatcher.locale.languageCode;

  @override
  void initState() {
    super.initState();
    final langs = widget.deck.availableLanguages;
    _l1 = langs.contains(_deviceLang) ? _deviceLang : langs.firstOrNull ?? 'cs';
    _l2 = langs.length > 1
        ? langs.firstWhere((l) => l != _l1, orElse: () => langs.first)
        : _l1;
    _style = widget.deck.defaultStyle.isNotEmpty
        ? widget.deck.defaultStyle
        : (widget.deck.styles.isNotEmpty ? widget.deck.styles.first : '');
  }

  LanguageDeck get _deck => widget.deck;
  EntitlementService get _ent => widget.entitlements;

  bool get _isActivated => _ent.isActivated(_deck.slug, _l1, _l2, _style);

  int get _cost => _ent.creditCostForTier(_deck.tier);

  // Preview cards: at most 3.
  List<LanguageCard> get _previewCards =>
      _deck.cards.take(3).toList();

  Future<void> _unlock() async {
    setState(() => _unlocking = true);
    final err = await _ent.unlockWithCredits(
      _deck.slug, _l1, _l2, _style,
      tier: _deck.tier,
    );
    if (!mounted) return;
    setState(() => _unlocking = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          action: SnackBarAction(
            label: 'Koupit kredity',
            onPressed: () => showCreditPackSheet(context, _ent),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Přidáno na domovskou obrazovku')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langs = _deck.availableLanguages;
    final cards = _previewCards;
    final card = cards.isEmpty ? null : cards[_previewIndex % cards.length];

    return Scaffold(
      appBar: AppBar(title: Text(_deck.title(_deviceLang))),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              children: [
                // Language pair picker
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

                // Style chips (only when multiple styles available)
                if (_deck.styles.length > 1) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: _deck.styles.map((s) {
                      return ChoiceChip(
                        label: Text(s),
                        selected: _style == s,
                        onSelected: (_) => setState(() => _style = s),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 16),

                // Card preview
                if (card != null) ...[
                  // Navigation: prev / counter / next (only first 3 cards)
                  if (cards.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _previewIndex > 0
                              ? () => setState(() => _previewIndex--)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                          label: const Text('Předchozí'),
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
                          label: const Text('Další'),
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
                  ),
                ],
              ],
            ),
          ),

          // Bottom action bar
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
                        const Icon(Icons.toll_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('${_ent.creditBalance} kreditů'),
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
                              '$activatedCount aktivní',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        TextButton(
                          onPressed: () =>
                              showCreditPackSheet(context, _ent),
                          child: const Text('+ Koupit kredity'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ActionButton(
                      tier: _deck.tier,
                      isActivated: _isActivated,
                      cost: _cost,
                      unlocking: _unlocking,
                      onUnlock: _unlock,
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

// ── Card preview ──────────────────────────────────────────────────────────────

class _CardPreview extends StatelessWidget {
  final LanguageCard card;
  final String l1;
  final String l2;
  final String slug;
  final String style;

  const _CardPreview({
    required this.card,
    required this.l1,
    required this.l2,
    required this.slug,
    required this.style,
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
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: card.image.isNotEmpty
                  ? Image.asset(
                      'decks/$slug/images/$style/${card.image}',
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 16),

            // Foreign side
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

            // Native side
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

  Widget _placeholder() => Container(
        height: 180,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined,
            size: 56, color: Colors.grey.shade400),
      );
}

// ── Language pair picker ──────────────────────────────────────────────────────

const _kLangNames = {
  'cs': '🇨🇿 Czech',
  'en': '🇬🇧 English',
  'zh-CN': '🇨🇳 Chinese',
  'hi': '🇮🇳 Hindi',
  'es-419': '🇲🇽 Spanish',
  'ar': '🇸🇦 Arabic',
  'fr': '🇫🇷 French',
  'bn': '🇧🇩 Bengali',
  'pt-BR': '🇧🇷 Portuguese',
  'ru': '🇷🇺 Russian',
  'id': '🇮🇩 Indonesian',
  'ur': '🇵🇰 Urdu',
  'de': '🇩🇪 German',
  'ja': '🇯🇵 Japanese',
  'mr': '🇮🇳 Marathi',
  'te': '🇮🇳 Telugu',
  'tr': '🇹🇷 Turkish',
  'ta': '🇱🇰 Tamil',
  'vi': '🇻🇳 Vietnamese',
  'ko': '🇰🇷 Korean',
  'ha': '🇳🇬 Hausa',
  'la': '🏛️ Latin',
  'sa': '🕉️ Sanskrit',
};

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
    return Row(
      children: [
        const Text('Znám '),
        _dropdown(l1, (v) => onChanged(v, l2)),
        const Text('  učím se '),
        _dropdown(l2, (v) => onChanged(l1, v)),
      ],
    );
  }

  Widget _dropdown(String value, ValueChanged<String> onChanged) {
    final safeValue = languages.contains(value) ? value : languages.firstOrNull ?? value;
    return DropdownButton<String>(
      value: safeValue,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      items: languages
          .map((l) => DropdownMenuItem(
                value: l,
                child: Text(_kLangNames[l] ?? l),
              ))
          .toList(),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final int tier;
  final bool isActivated;
  final int cost;
  final bool unlocking;
  final VoidCallback onUnlock;

  const _ActionButton({
    required this.tier,
    required this.isActivated,
    required this.cost,
    required this.unlocking,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    if (isActivated) {
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_rounded),
        label: const Text('Aktivní'),
      );
    }
    if (tier == 0) {
      return FilledButton.icon(
        onPressed: unlocking ? null : onUnlock,
        icon: unlocking
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_rounded),
        label: const Text('Přidat zdarma'),
      );
    }
    return FilledButton.tonal(
      onPressed: unlocking ? null : onUnlock,
      child: unlocking
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text('Odemknout za $cost kr.'),
    );
  }
}
