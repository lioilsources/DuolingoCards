// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Tienda de mazos';

  @override
  String get homeEmptyTitle => 'Aún no tienes mazos';

  @override
  String get homeReorderHint =>
      'Mantén pulsado un mazo y arrástralo para cambiar el orden';

  @override
  String get homeBrowseStore => 'Ver la tienda de mazos';

  @override
  String get homeDownloadingDecks => 'Preparando tus mazos…';

  @override
  String get badgeFree => 'Gratis';

  @override
  String get badgeUnlocked => 'Desbloqueado';

  @override
  String get badgePurchased => 'Comprado';

  @override
  String get badgeNew => 'Nuevo';

  @override
  String get badgePaidDeck => 'Mazo de pago';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarjetas',
      one: '1 tarjeta',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards tarjetas',
      one: '1 tarjeta',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs idiomas',
      one: '1 idioma',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count conocidas';
  }

  @override
  String legendLearning(int count) {
    return '$count aprendiendo';
  }

  @override
  String legendUnknown(int count) {
    return '$count desconocidas';
  }

  @override
  String get storeTitle => 'Tienda de mazos';

  @override
  String get storeRestorePurchases => 'Restaurar compras';

  @override
  String get storeSearchHint => 'Buscar mazos…';

  @override
  String storeLoadError(String error) {
    return 'No se pudieron cargar los mazos: $error';
  }

  @override
  String get storeNoDecks => 'No hay mazos disponibles.';

  @override
  String get storeNothingFound => 'No se encontró nada.';

  @override
  String get retry => 'Reintentar';

  @override
  String get buy => 'Comprar';

  @override
  String buyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String get add => 'Añadir';

  @override
  String get addFree => 'Añadir gratis';

  @override
  String get back => 'Atrás';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get study => 'Estudiar';

  @override
  String get download => 'Descargar';

  @override
  String get confirmLanguagesLabel => 'Idiomas';

  @override
  String get styleSectionTitle => 'Estilo de imagen';

  @override
  String get confirmBuyNote =>
      'Al comprar desbloqueas el mazo completo: todos los idiomas y todos los estilos. Esta combinación se añadirá a tu pantalla de inicio.';

  @override
  String get confirmAddNote =>
      'Esta combinación se añadirá a tu pantalla de inicio. Puedes añadir otro idioma u otro estilo cuando quieras.';

  @override
  String get purchaseFailedToStart => 'No se pudo iniciar la compra.';

  @override
  String get addedToHome => 'Añadido a tu pantalla de inicio.';

  @override
  String get downloadFailed => 'Error en la descarga. Inténtalo de nuevo.';

  @override
  String get deckNotPurchased => 'Este mazo no se ha comprado.';

  @override
  String downloading(int percent) {
    return 'Descargando… $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activas',
      one: '1 activa',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Me la sé';

  @override
  String get pickerLearning => 'Aprendiendo';

  @override
  String get reportIssue => 'Informar de un problema';

  @override
  String get issueTranslation => 'Traducción';

  @override
  String get issueImage => 'Imagen';

  @override
  String get issuePronunciation => 'Pronunciación';

  @override
  String get issueMeaning => 'Significado / datos';

  @override
  String get issueOther => 'Otro';

  @override
  String get feedbackCommentHint => '¿Qué está mal? (opcional)';

  @override
  String get feedbackSend => 'Enviar por correo';

  @override
  String feedbackNoMailApp(String email) {
    return 'No hay ninguna app de correo disponible. El informe se copió al portapapeles; envíalo a $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problema con la tarjeta $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Mazo: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Tarjeta: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Idiomas: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Mostrado: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Estilo: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Tipo de problema: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Para: $email';
  }

  @override
  String get pronounce => 'Pronunciar';

  @override
  String get installVoice => 'Instalar voz';

  @override
  String noVoiceInstalled(String lang) {
    return 'No hay ninguna voz instalada para «$lang». Añade una en Ajustes → Accesibilidad → Contenido leído → Voces y vuelve a intentarlo.';
  }

  @override
  String get playPronunciation => 'Escuchar pronunciación';

  @override
  String get swipeNext => 'SIGUIENTE';

  @override
  String get swipeBack => 'ATRÁS';

  @override
  String get showTranslation => 'Ver traducción';

  @override
  String get showOriginal => 'Ver original';

  @override
  String get noCards => 'Sin tarjetas';

  @override
  String get deckHasNoCards => 'Este mazo no tiene tarjetas.';

  @override
  String get flashcards => 'Tarjetas';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc => 'Fotografía nítida, lo más fiel a la realidad';

  @override
  String get styleInk => 'Pincel y tinta';

  @override
  String get styleInkDesc => 'Pinceladas, papel desnudo, un toque de color';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Pastel seco sobre papel tintado';

  @override
  String get styleWatercolor => 'Acuarela';

  @override
  String get styleWatercolorDesc => 'Aguadas que se expanden, papel a la vista';

  @override
  String get styleFlag => 'Banderas';

  @override
  String get styleFlagDesc => 'Las banderas nacionales reales';

  @override
  String get stylePonyCartoon => 'Dibujos animados';

  @override
  String get stylePonyCartoonDesc => 'Ilustración colorida de dibujos animados';

  @override
  String get styleStorybook => 'Cuento ilustrado';

  @override
  String get styleStorybookDesc => 'Ilustración suave de libro';

  @override
  String get stylePonyWatercolor => 'Acuarela suave';

  @override
  String get stylePonyWatercolorDesc => 'Pintura de acuarela delicada';

  @override
  String get stylePonyOil => 'Pintura al óleo';

  @override
  String get stylePonyOilDesc => 'Pinceladas gruesas sobre lienzo';

  @override
  String get styleIllustriousOil => 'Óleo – empaste';

  @override
  String get styleIllustriousOilDesc => 'Pintura espesa, claroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Dibujo de anime japonés';

  @override
  String get styleFlat => 'Vector plano';

  @override
  String get styleFlatDesc => 'Colores planos y formas limpias';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Grabado japonés en madera';

  @override
  String get styleMucha => 'Art nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Art nouveau ornamental con detalles dorados';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Pinceladas arremolinadas posimpresionistas';

  @override
  String get styleVectorFlat => 'Vector plano';

  @override
  String get styleVectorFlatDesc =>
      'Formas planas nítidas con contornos limpios';

  @override
  String get styleGouache => 'Gouache';

  @override
  String get styleGouacheDesc => 'Pintura opaca y mate en colores intensos';

  @override
  String get styleWatercolorWet => 'Acuarela húmeda';

  @override
  String get styleWatercolorWetDesc =>
      'Colores que se funden en el papel mojado';

  @override
  String get styleWatercolorInkLine => 'Tinta y acuarela';

  @override
  String get styleWatercolorInkLineDesc =>
      'Finas líneas de tinta con aguadas suaves';

  @override
  String get styleEtching => 'Grabado';

  @override
  String get styleEtchingDesc =>
      'Finas líneas grabadas, como una estampa antigua';

  @override
  String get styleLinocut => 'Linograbado';

  @override
  String get styleLinocutDesc => 'Formas talladas impresas en pocos colores';

  @override
  String get styleCrayon => 'Crayones';

  @override
  String get styleCrayonDesc => 'Trazos de crayón, como un dibujo infantil';

  @override
  String get styleLowPoly => 'Low poly';

  @override
  String get styleLowPolyDesc => 'Hecho de triángulos con sombreado plano';

  @override
  String get styleClaymation => 'Plastilina';

  @override
  String get styleClaymationDesc => 'Modelado en plastilina suave';

  @override
  String get styleStickerCollage => 'Collage de stickers';

  @override
  String get styleStickerCollageDesc => 'Stickers recortados con borde blanco';

  @override
  String get stylePressedFlowers => 'Flores prensadas';

  @override
  String get stylePressedFlowersDesc => 'Hecho con pétalos y hojas secos';

  @override
  String get stylePaperSculptureLayered => 'Papel recortado';

  @override
  String get stylePaperSculptureLayeredDesc =>
      'Capas de papel recortado con sombras suaves';

  @override
  String get stylePolishPoster => 'Póster retro';

  @override
  String get stylePolishPosterDesc => 'Cartelismo audaz de mediados de siglo';

  @override
  String get styleChalkboard => 'Pizarrón';

  @override
  String get styleChalkboardDesc => 'Dibujo con tiza en un pizarrón oscuro';

  @override
  String get styleBlueprint => 'Plano técnico';

  @override
  String get styleBlueprintDesc => 'Líneas técnicas blancas sobre azul';

  @override
  String get styleIllumination => 'Manuscrito iluminado';

  @override
  String get styleIlluminationDesc => 'Arte de libro medieval con pan de oro';

  @override
  String get styleRackham => 'Tinta de cuento';

  @override
  String get styleRackhamDesc =>
      'Delicadas líneas de tinta y aguadas tenues de viejos libros de cuentos';

  @override
  String get styleMoebius => 'Dibujo de cómic';

  @override
  String get styleMoebiusDesc =>
      'Líneas de cómic limpias y colores planos brillantes';

  @override
  String get styleHiroshige => 'Grabado japonés';

  @override
  String get styleHiroshigeDesc =>
      'Paisaje japonés grabado en madera con degradados suaves';

  @override
  String get langAr => 'Árabe';

  @override
  String get langCs => 'Checo';

  @override
  String get langDe => 'Alemán';

  @override
  String get langEl => 'Griego';

  @override
  String get langEn => 'Inglés';

  @override
  String get langEs419 => 'Español';

  @override
  String get langFr => 'Francés';

  @override
  String get langHe => 'Hebreo';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonesio';

  @override
  String get langJa => 'Japonés';

  @override
  String get langKo => 'Coreano';

  @override
  String get langPtBR => 'Portugués';

  @override
  String get langRu => 'Ruso';

  @override
  String get langTr => 'Turco';

  @override
  String get langVi => 'Vietnamita';

  @override
  String get langZhCN => 'Chino';
}
