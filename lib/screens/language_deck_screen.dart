import 'package:flutter/material.dart';

import '../models/language_deck.dart';
import '../utils/language_names.dart';
import '../utils/locale_direction.dart';
import '../widgets/pronounce_button.dart';

/// Minimal browser for a no-backend [LanguageDeck].
///
/// Demonstrates the v2 learning-card stack end to end: a native→foreign
/// language pair, the foreign side (label + summary) with on-device TTS, the
/// native side (label + info), and per-string RTL via [DirectionalText].
class LanguageDeckScreen extends StatefulWidget {
  final LanguageDeck deck;

  /// Learner's native language (L1) and the language being learned (L2).
  final String nativeLang;
  final String foreignLang;

  /// Image style to use; falls back to [LanguageDeck.defaultStyle].
  final String? initialStyle;

  const LanguageDeckScreen({
    super.key,
    required this.deck,
    this.nativeLang = 'cs',
    this.foreignLang = 'en',
    this.initialStyle,
  });

  @override
  State<LanguageDeckScreen> createState() => _LanguageDeckScreenState();
}

class _LanguageDeckScreenState extends State<LanguageDeckScreen> {
  late String _l1;
  late String _l2;
  late String _style;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final langs = widget.deck.availableLanguages;
    _l1 = langs.contains(widget.nativeLang)
        ? widget.nativeLang
        : (langs.isNotEmpty ? langs.first : 'cs');
    _l2 = langs.contains(widget.foreignLang)
        ? widget.foreignLang
        : (langs.length > 1 ? langs[1] : _l1);
    _style = widget.initialStyle ?? widget.deck.defaultStyle;
  }

  @override
  Widget build(BuildContext context) {
    final deck = widget.deck;
    final cards = deck.cards;
    final card = cards.isEmpty ? null : cards[_index % cards.length];

    return Scaffold(
      appBar: AppBar(title: Text(deck.title(_l1))),
      body: Column(
        children: [
          _LangPairPicker(
            languages: deck.availableLanguages,
            l1: _l1,
            l2: _l2,
            onChanged: (l1, l2) => setState(() {
              _l1 = l1;
              _l2 = l2;
            }),
          ),
          const Divider(height: 1),
          Expanded(
            child: card == null
                ? const Center(child: Text('This deck has no cards.'))
                : _CardView(
                    card: card,
                    l1: _l1,
                    l2: _l2,
                    slug: deck.slug,
                    style: _style,
                  ),
          ),
          if (cards.length > 1)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(
                        () => _index = (_index - 1 + cards.length) % cards.length),
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Prev'),
                  ),
                  Text('${(_index % cards.length) + 1} / ${cards.length}'),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _index = (_index + 1) % cards.length),
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CardView extends StatelessWidget {
  final LanguageCard card;
  final String l1;
  final String l2;
  final String slug;
  final String style;

  const _CardView({
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

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: card.image.isNotEmpty
              ? Image.asset(
                  'decks/$slug/images/$style/${card.image}',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => _imagePlaceholder(),
                )
              : _imagePlaceholder(),
        ),
        const SizedBox(height: 24),

        // Foreign side: label + summary, with pronunciation.
        Row(
          children: [
            Expanded(
              child: DirectionalText(
                foreignLabel,
                lang: l2,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            PronounceButton(text: foreignLabel, lang: l2),
          ],
        ),
        if (foreignSummary.isNotEmpty) ...[
          const SizedBox(height: 8),
          DirectionalText(foreignSummary,
              lang: l2, style: theme.textTheme.bodyLarge),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(),
        ),

        // Native side: label + full info text.
        DirectionalText(
          nativeLabel,
          lang: l1,
          style: theme.textTheme.titleLarge
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        if (nativeInfo.isNotEmpty) ...[
          const SizedBox(height: 8),
          DirectionalText(nativeInfo,
              lang: l1, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }

  Widget _imagePlaceholder() => Container(
        height: 220,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, size: 56, color: Colors.grey.shade400),
      );
}


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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('I speak '),
          _dropdown(l1, (v) => onChanged(v, l2)),
          const Text('  learning '),
          _dropdown(l2, (v) => onChanged(l1, v)),
        ],
      ),
    );
  }

  Widget _dropdown(String value, ValueChanged<String> onChanged) {
    return DropdownButton<String>(
      value: value,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      items: languages
          .map((l) => DropdownMenuItem(value: l, child: Text(kLangNames[l] ?? l)))
          .toList(),
    );
  }
}
