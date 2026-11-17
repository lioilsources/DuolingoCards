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
    // Not a look but the subject itself: geo-flags shows the real flags.
    CardStyle(id: 'flag', icon: Icons.flag_outlined),
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
    // Second wave of presets: techniques and media rather than models.
    CardStyle(id: 'vector-flat', icon: Icons.shape_line_outlined),
    CardStyle(id: 'gouache', icon: Icons.format_color_fill_outlined),
    CardStyle(id: 'watercolor-wet', icon: Icons.opacity_outlined),
    CardStyle(id: 'watercolor-ink-line', icon: Icons.draw_outlined),
    CardStyle(id: 'etching', icon: Icons.texture_outlined),
    CardStyle(id: 'linocut', icon: Icons.carpenter_outlined),
    CardStyle(id: 'crayon', icon: Icons.edit_outlined),
    CardStyle(id: 'low-poly', icon: Icons.change_history_outlined),
    CardStyle(id: 'claymation', icon: Icons.toys_outlined),
    CardStyle(id: 'sticker-collage', icon: Icons.sticky_note_2_outlined),
    CardStyle(id: 'pressed-flowers', icon: Icons.eco_outlined),
    CardStyle(id: 'paper-sculpture-layered', icon: Icons.layers_outlined),
    CardStyle(id: 'polish-poster', icon: Icons.campaign_outlined),
    CardStyle(id: 'chalkboard', icon: Icons.school_outlined),
    CardStyle(id: 'blueprint', icon: Icons.architecture_outlined),
    CardStyle(id: 'illumination', icon: Icons.menu_book_outlined),
    CardStyle(id: 'rackham', icon: Icons.forest_outlined),
    CardStyle(id: 'moebius', icon: Icons.gesture_outlined),
    CardStyle(id: 'hiroshige', icon: Icons.landscape_outlined),
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
        'flag' => l10n.styleFlag,
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
        'vector-flat' => l10n.styleVectorFlat,
        'gouache' => l10n.styleGouache,
        'watercolor-wet' => l10n.styleWatercolorWet,
        'watercolor-ink-line' => l10n.styleWatercolorInkLine,
        'etching' => l10n.styleEtching,
        'linocut' => l10n.styleLinocut,
        'crayon' => l10n.styleCrayon,
        'low-poly' => l10n.styleLowPoly,
        'claymation' => l10n.styleClaymation,
        'sticker-collage' => l10n.styleStickerCollage,
        'pressed-flowers' => l10n.stylePressedFlowers,
        'paper-sculpture-layered' => l10n.stylePaperSculptureLayered,
        'polish-poster' => l10n.stylePolishPoster,
        'chalkboard' => l10n.styleChalkboard,
        'blueprint' => l10n.styleBlueprint,
        'illumination' => l10n.styleIllumination,
        'rackham' => l10n.styleRackham,
        'moebius' => l10n.styleMoebius,
        'hiroshige' => l10n.styleHiroshige,
        _ => _prettify(id),
      };

  /// One-line description of the look; empty for unknown ids.
  String description(AppLocalizations l10n) => switch (id) {
        'photo' => l10n.stylePhotoDesc,
        'ink' => l10n.styleInkDesc,
        'pastel' => l10n.stylePastelDesc,
        'watercolor' => l10n.styleWatercolorDesc,
        'flag' => l10n.styleFlagDesc,
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
        'vector-flat' => l10n.styleVectorFlatDesc,
        'gouache' => l10n.styleGouacheDesc,
        'watercolor-wet' => l10n.styleWatercolorWetDesc,
        'watercolor-ink-line' => l10n.styleWatercolorInkLineDesc,
        'etching' => l10n.styleEtchingDesc,
        'linocut' => l10n.styleLinocutDesc,
        'crayon' => l10n.styleCrayonDesc,
        'low-poly' => l10n.styleLowPolyDesc,
        'claymation' => l10n.styleClaymationDesc,
        'sticker-collage' => l10n.styleStickerCollageDesc,
        'pressed-flowers' => l10n.stylePressedFlowersDesc,
        'paper-sculpture-layered' => l10n.stylePaperSculptureLayeredDesc,
        'polish-poster' => l10n.stylePolishPosterDesc,
        'chalkboard' => l10n.styleChalkboardDesc,
        'blueprint' => l10n.styleBlueprintDesc,
        'illumination' => l10n.styleIlluminationDesc,
        'rackham' => l10n.styleRackhamDesc,
        'moebius' => l10n.styleMoebiusDesc,
        'hiroshige' => l10n.styleHiroshigeDesc,
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
