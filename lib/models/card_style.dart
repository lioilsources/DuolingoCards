import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Presentation metadata for a card image style.
///
/// The pipeline names styles after the model that renders them
/// (`illustrious-ukiyoe`), which is the right key for `decks/<slug>/images/`
/// but the wrong thing to put in front of a buyer. This maps each id to an
/// icon and — through [AppLocalizations] — a name and a one-line description
/// of the look in the UI language.
///
/// Unknown ids degrade to a prettified slug rather than throwing, so a style
/// added to the pipeline still renders sanely in an app build that predates it.
@immutable
class CardStyle {
  final String id;
  final IconData icon;

  const CardStyle({required this.id, required this.icon});

  /// Registry order is presentation order. The four styles the decks actually
  /// declare come first — every deck ships [photo] plus exactly one illustrated
  /// look. The rest are presets the pipeline can render but no deck.yaml lists;
  /// they stay here so a deck that adopts one later renders sanely.
  static const List<CardStyle> all = [
    CardStyle(id: 'photo', icon: Icons.photo_camera_outlined),
    CardStyle(id: 'ink', icon: Icons.water_outlined),
    CardStyle(id: 'pastel', icon: Icons.gradient_outlined),
    CardStyle(id: 'watercolor', icon: Icons.local_florist_outlined),
    CardStyle(id: 'pony-cartoon', icon: Icons.brush_outlined),
    CardStyle(id: 'illustrious-storybook', icon: Icons.auto_stories_outlined),
    CardStyle(id: 'pony-watercolor', icon: Icons.water_drop_outlined),
    CardStyle(id: 'pony-oil', icon: Icons.palette_outlined),
    CardStyle(id: 'illustrious-oil', icon: Icons.format_paint_outlined),
    CardStyle(id: 'illustrious-anime', icon: Icons.animation_outlined),
    CardStyle(id: 'illustrious-flat', icon: Icons.category_outlined),
    CardStyle(id: 'illustrious-ukiyoe', icon: Icons.filter_vintage_outlined),
    CardStyle(id: 'illustrious-mucha', icon: Icons.auto_awesome_outlined),
    CardStyle(id: 'illustrious-vangogh', icon: Icons.cyclone_outlined),
  ];

  static final Map<String, CardStyle> _byId = {
    for (final s in all) s.id: s,
  };

  /// Metadata for [id], synthesised from the slug when the id is unknown.
  static CardStyle of(String id) =>
      _byId[id] ?? CardStyle(id: id, icon: Icons.image_outlined);

  /// Human-readable name for [id] — the one-liner used in tags and chips.
  static String labelOf(String id, AppLocalizations l10n) => of(id).label(l10n);

  /// Name of the style in the UI language; a prettified slug for ids this
  /// build does not know.
  String label(AppLocalizations l10n) => switch (id) {
        'photo' => l10n.stylePhoto,
        'ink' => l10n.styleInk,
        'pastel' => l10n.stylePastel,
        'watercolor' => l10n.styleWatercolor,
        'pony-cartoon' => l10n.stylePonyCartoon,
        'illustrious-storybook' => l10n.styleStorybook,
        'pony-watercolor' => l10n.stylePonyWatercolor,
        'pony-oil' => l10n.stylePonyOil,
        'illustrious-oil' => l10n.styleIllustriousOil,
        'illustrious-anime' => l10n.styleAnime,
        'illustrious-flat' => l10n.styleFlat,
        'illustrious-ukiyoe' => l10n.styleUkiyoe,
        'illustrious-mucha' => l10n.styleMucha,
        'illustrious-vangogh' => l10n.styleVanGogh,
        _ => _prettify(id),
      };

  /// One-line description of the look; empty for unknown ids.
  String description(AppLocalizations l10n) => switch (id) {
        'photo' => l10n.stylePhotoDesc,
        'ink' => l10n.styleInkDesc,
        'pastel' => l10n.stylePastelDesc,
        'watercolor' => l10n.styleWatercolorDesc,
        'pony-cartoon' => l10n.stylePonyCartoonDesc,
        'illustrious-storybook' => l10n.styleStorybookDesc,
        'pony-watercolor' => l10n.stylePonyWatercolorDesc,
        'pony-oil' => l10n.stylePonyOilDesc,
        'illustrious-oil' => l10n.styleIllustriousOilDesc,
        'illustrious-anime' => l10n.styleAnimeDesc,
        'illustrious-flat' => l10n.styleFlatDesc,
        'illustrious-ukiyoe' => l10n.styleUkiyoeDesc,
        'illustrious-mucha' => l10n.styleMuchaDesc,
        'illustrious-vangogh' => l10n.styleVanGoghDesc,
        _ => '',
      };

  /// "illustrious-ukiyoe" → "Illustrious ukiyoe".
  static String _prettify(String id) {
    if (id.isEmpty) return id;
    final words = id.replaceAll('-', ' ').replaceAll('_', ' ');
    return words[0].toUpperCase() + words.substring(1);
  }

  /// Sorts [ids] into registry order, keeping unknown ids at the end in their
  /// original relative order.
  static List<String> sorted(Iterable<String> ids) {
    final rank = {for (var i = 0; i < all.length; i++) all[i].id: i};
    final list = ids.toList();
    final original = {for (var i = 0; i < list.length; i++) list[i]: i};
    list.sort((a, b) {
      final ra = rank[a] ?? all.length + original[a]!;
      final rb = rank[b] ?? all.length + original[b]!;
      return ra.compareTo(rb);
    });
    return list;
  }
}
