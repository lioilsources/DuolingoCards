import 'package:flutter/material.dart';

/// Presentation metadata for a card image style.
///
/// The pipeline names styles after the model that renders them
/// (`illustrious-ukiyoe`), which is the right key for `decks/<slug>/images/`
/// but the wrong thing to put in front of a buyer. This maps each id to a name
/// and a one-line description of the look.
///
/// Unknown ids degrade to a prettified slug rather than throwing, so a style
/// added to the pipeline still renders sanely in an app build that predates it.
@immutable
class CardStyle {
  final String id;
  final String label;
  final String description;
  final IconData icon;

  const CardStyle({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });

  /// Registry order is presentation order: photographic first, then the
  /// illustrated looks from most to least literal.
  /// Registry order is presentation order. The four styles the decks actually
  /// declare come first — every deck ships [photo] plus exactly one illustrated
  /// look. The rest are presets the pipeline can render but no deck.yaml lists;
  /// they stay here so a deck that adopts one later renders sanely.
  static const List<CardStyle> all = [
    CardStyle(
      id: 'photo',
      label: 'Fotografie',
      description: 'Ostrá fotografie, nejblíž skutečnosti',
      icon: Icons.photo_camera_outlined,
    ),
    CardStyle(
      id: 'ink',
      label: 'Štětec a tuš',
      description: 'Tahy štětcem, prázdný papír, barevný akcent',
      icon: Icons.water_outlined,
    ),
    CardStyle(
      id: 'pastel',
      label: 'Pastel',
      description: 'Suchý pastel na tónovaném papíře',
      icon: Icons.gradient_outlined,
    ),
    CardStyle(
      id: 'watercolor',
      label: 'Akvarel',
      description: 'Rozpité lazury, prosvítající papír',
      icon: Icons.local_florist_outlined,
    ),
    CardStyle(
      id: 'pony-cartoon',
      label: 'Kreslený',
      description: 'Barevná kreslená ilustrace',
      icon: Icons.brush_outlined,
    ),
    CardStyle(
      id: 'illustrious-storybook',
      label: 'Pohádková kniha',
      description: 'Jemná knižní ilustrace',
      icon: Icons.auto_stories_outlined,
    ),
    CardStyle(
      id: 'pony-watercolor',
      label: 'Akvarel – měkký',
      description: 'Měkká malba vodovkami',
      icon: Icons.water_drop_outlined,
    ),
    CardStyle(
      id: 'pony-oil',
      label: 'Olejomalba',
      description: 'Hutné tahy štětcem na plátně',
      icon: Icons.palette_outlined,
    ),
    CardStyle(
      id: 'illustrious-oil',
      label: 'Olej – impasto',
      description: 'Nanesená pastózní barva, šerosvit',
      icon: Icons.format_paint_outlined,
    ),
    CardStyle(
      id: 'illustrious-anime',
      label: 'Anime',
      description: 'Japonská anime kresba',
      icon: Icons.animation_outlined,
    ),
    CardStyle(
      id: 'illustrious-flat',
      label: 'Plochý vektor',
      description: 'Ploché barvy a čisté tvary',
      icon: Icons.category_outlined,
    ),
    CardStyle(
      id: 'illustrious-ukiyoe',
      label: 'Ukijo-e',
      description: 'Japonský dřevoryt',
      icon: Icons.filter_vintage_outlined,
    ),
    CardStyle(
      id: 'illustrious-mucha',
      label: 'Secese (Mucha)',
      description: 'Ornamentální art nouveau se zlatými akcenty',
      icon: Icons.auto_awesome_outlined,
    ),
    CardStyle(
      id: 'illustrious-vangogh',
      label: 'Van Gogh',
      description: 'Postimpresionistické vířivé tahy',
      icon: Icons.cyclone_outlined,
    ),
  ];

  static final Map<String, CardStyle> _byId = {
    for (final s in all) s.id: s,
  };

  /// Metadata for [id], synthesised from the slug when the id is unknown.
  static CardStyle of(String id) => _byId[id] ?? _unknown(id);

  /// Human-readable name for [id] — the one-liner used in tags and chips.
  static String labelOf(String id) => of(id).label;

  static CardStyle _unknown(String id) => CardStyle(
        id: id,
        label: _prettify(id),
        description: '',
        icon: Icons.image_outlined,
      );

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
