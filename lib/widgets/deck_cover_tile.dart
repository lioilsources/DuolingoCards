import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/cdn_config.dart';
import '../l10n/app_localizations.dart';
import '../models/card_style.dart';
import '../models/deck_palette.dart';
import '../models/language_deck.dart';
import '../services/priority_service.dart';
import '../utils/language_names.dart';
import '../utils/locale_direction.dart';

/// One deck on the home screen: a cover of the three cards the learner knows
/// least, side by side in the tile's image style, over title, language pair,
/// style and progress.
///
/// The cover changes as the learner studies — the trio is always what is
/// worth practising next — so the home screen doubles as a nudge.
class DeckCoverTile extends StatelessWidget {
  const DeckCoverTile({
    super.key,
    required this.deck,
    required this.l1,
    required this.l2,
    required this.style,
    required this.coverCards,
    required this.isFree,
    required this.onTap,
    this.stats,
    this.docsDir,
  });

  final LanguageDeck deck;
  final String l1;
  final String l2;
  final String style;

  /// Up to three cards for the cover, least known first
  /// (see [PriorityService.leastKnown]).
  final List<LanguageCard> coverCards;
  final PriorityStats? stats;
  final bool isFree;
  final VoidCallback onTap;

  /// App documents directory, where downloaded deck images live.
  final String? docsDir;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = DeckPalette.of(deck.slug);
    final theme = Theme.of(context);
    // Deck titles are chrome, so they follow the UI language like every other
    // label on the tile; the pair itself is spelled out in the subtitle.
    final uiLang = Localizations.localeOf(context).languageCode;
    final flag = langFlag(l2);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: palette.background,
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: palette.accent.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CoverStrip(
                cards: coverCards,
                slug: deck.slug,
                style: style,
                l2: l2,
                docsDir: docsDir,
                palette: palette,
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      deck.title(uiLang),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Badge(isFree: isFree),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${flag != null ? '$flag  ' : ''}'
                    '${l10n.tileCardsAndPair(deck.cards.length, l1.toUpperCase(), l2.toUpperCase())}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  _StyleTag(style: style),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (stats != null)
                    Expanded(child: _KnowledgeProgressBar(stats: stats!))
                  else
                    const Spacer(),
                  const SizedBox(width: 12),
                  _PlayButton(color: palette.accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three thumbnails side by side, the outer two tilted outwards a little and
/// the middle one lifted — the in-app-review fan opened up so every picture
/// stays fully visible.
class _CoverStrip extends StatelessWidget {
  const _CoverStrip({
    required this.cards,
    required this.slug,
    required this.style,
    required this.l2,
    required this.docsDir,
    required this.palette,
  });

  final List<LanguageCard> cards;
  final String slug;
  final String style;
  final String l2;
  final String? docsDir;
  final DeckPalette palette;

  static const _gap = 12.0;
  static const _tilt = [-4.0, 0.0, 4.0]; // degrees
  static const _lift = [0.0, -8.0, 0.0];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final thumb = (constraints.maxWidth - 2 * _gap) / 3;
        final dpr = MediaQuery.devicePixelRatioOf(context);
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cards.length && i < 3; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                Transform.translate(
                  offset: Offset(0, _lift[i]),
                  child: Transform.rotate(
                    angle: _tilt[i] * math.pi / 180,
                    child: _Thumb(
                      card: cards[i],
                      width: thumb,
                      cacheWidth: (thumb * dpr).round(),
                      slug: slug,
                      style: style,
                      l2: l2,
                      docsDir: docsDir,
                      palette: palette,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.card,
    required this.width,
    required this.cacheWidth,
    required this.slug,
    required this.style,
    required this.l2,
    required this.docsDir,
    required this.palette,
  });

  final LanguageCard card;
  final double width;
  final int cacheWidth;
  final String slug;
  final String style;
  final String l2;
  final String? docsDir;
  final DeckPalette palette;

  @override
  Widget build(BuildContext context) {
    final word = card.foreignLabel(l2);
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(color: palette.background, child: _image()),
            ),
          ),
          if (word != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: DirectionalText(
                word,
                lang: l2,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.grey.shade800),
              ),
            ),
        ],
      ),
    );
  }

  /// Same source order as the study card: downloaded file → bundled preview
  /// → CDN, so the cover works offline once a deck is on home.
  Widget _image() {
    final image = card.image;
    final placeholder = Icon(Icons.image_outlined, color: palette.accent);
    if (image.isEmpty) return placeholder;
    final dir = docsDir;
    if (dir != null) {
      final file = File('$dir/decks/$slug/images/$style/$image');
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          errorBuilder: (_, _, _) => placeholder,
        );
      }
    }
    return Image.asset(
      'assets/previews/$slug/$style/$image',
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      errorBuilder: (_, _, _) => CachedNetworkImage(
        imageUrl: '$kCdnBaseUrl/decks/$slug/images/$style/$image',
        fit: BoxFit.cover,
        memCacheWidth: cacheWidth,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.isFree});
  final bool isFree;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isFree ? Colors.green.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isFree ? l10n.badgeFree : l10n.badgeUnlocked,
        style: TextStyle(
          fontSize: 12,
          color: isFree ? Colors.green.shade800 : Colors.blue.shade800,
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Decorative: the whole tile is the tap target.
    return ExcludeSemantics(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          size: 28,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}

/// The image style a deck was unlocked with.
///
/// Style is part of the entitlement key, so the same deck can appear twice on
/// home differing only by look — the tag is what tells them apart.
class _StyleTag extends StatelessWidget {
  final String style;
  const _StyleTag({required this.style});

  @override
  Widget build(BuildContext context) {
    final meta = CardStyle.of(style);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 13, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            meta.label(AppLocalizations.of(context)),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeProgressBar extends StatelessWidget {
  final PriorityStats stats;

  const _KnowledgeProgressBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (stats.knownPercent > 0)
                  Expanded(
                    flex: (stats.knownPercent * 100).round(),
                    child: Container(color: Colors.green.shade400),
                  ),
                if (stats.learningPercent > 0)
                  Expanded(
                    flex: (stats.learningPercent * 100).round(),
                    child: Container(color: Colors.amber.shade400),
                  ),
                if (stats.unknownPercent > 0)
                  Expanded(
                    flex: (stats.unknownPercent * 100).round(),
                    child: Container(color: Colors.red.shade400),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        // The bar alone reads as a divider on a fresh deck (everything starts
        // at priority 5 → one solid amber strip); the counts are what make it
        // legible as progress.
        Wrap(
          spacing: 10,
          children: [
            _LegendEntry(
              color: Colors.green.shade400,
              text: l10n.legendKnown(stats.known),
            ),
            _LegendEntry(
              color: Colors.amber.shade400,
              text: l10n.legendLearning(stats.learning),
            ),
            _LegendEntry(
              color: Colors.red.shade400,
              text: l10n.legendUnknown(stats.unknown),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendEntry({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
