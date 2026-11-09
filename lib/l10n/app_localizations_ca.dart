// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Botiga de baralles';

  @override
  String get homeEmptyTitle => 'Encara no tens baralles';

  @override
  String get homeReorderHint =>
      'Mantén premuda una baralla i arrossega-la per canviar-ne l\'ordre';

  @override
  String get homeBrowseStore => 'Explora la botiga de baralles';

  @override
  String get homeDownloadingDecks => 'Estem preparant les teves baralles…';

  @override
  String get badgeFree => 'Gratuïta';

  @override
  String get badgeUnlocked => 'Desbloquejada';

  @override
  String get badgePurchased => 'Comprada';

  @override
  String get badgePaidDeck => 'Baralla de pagament';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count targetes',
      one: '1 targeta',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards targetes',
      one: '1 targeta',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs idiomes',
      one: '1 idioma',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count conegudes';
  }

  @override
  String legendLearning(int count) {
    return '$count en aprenentatge';
  }

  @override
  String legendUnknown(int count) {
    return '$count desconegudes';
  }

  @override
  String get storeTitle => 'Botiga de baralles';

  @override
  String get storeRestorePurchases => 'Restaura les compres';

  @override
  String get storeSearchHint => 'Cerca baralles…';

  @override
  String storeLoadError(String error) {
    return 'No s\'han pogut carregar les baralles: $error';
  }

  @override
  String get storeNoDecks => 'No hi ha baralles disponibles.';

  @override
  String get storeNothingFound => 'No s\'ha trobat res.';

  @override
  String get retry => 'Torna-ho a provar';

  @override
  String get buy => 'Compra';

  @override
  String buyFor(String price) {
    return 'Compra per $price';
  }

  @override
  String get add => 'Afegeix';

  @override
  String get addFree => 'Afegeix gratis';

  @override
  String get back => 'Enrere';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Següent';

  @override
  String get study => 'Estudia';

  @override
  String get download => 'Baixa';

  @override
  String get confirmLanguagesLabel => 'Idiomes';

  @override
  String get styleSectionTitle => 'Estil de les imatges';

  @override
  String get confirmBuyNote =>
      'La compra desbloqueja tota la baralla: tots els idiomes i tots els estils. Aquesta combinació s\'afegirà a la pantalla d\'inici.';

  @override
  String get confirmAddNote =>
      'Aquesta combinació s\'afegirà a la pantalla d\'inici. Pots afegir un altre idioma o estil quan vulguis.';

  @override
  String get purchaseFailedToStart => 'No s\'ha pogut iniciar la compra.';

  @override
  String get addedToHome => 'S\'ha afegit a la pantalla d\'inici.';

  @override
  String get downloadFailed => 'La baixada ha fallat. Torna-ho a provar.';

  @override
  String get deckNotPurchased => 'Aquesta baralla no s\'ha comprat.';

  @override
  String downloading(int percent) {
    return 'S\'està baixant… $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actives',
      one: '1 activa',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'La sé';

  @override
  String get pickerLearning => 'L\'estic aprenent';

  @override
  String get reportIssue => 'Informa d\'un problema';

  @override
  String get issueTranslation => 'Traducció';

  @override
  String get issueImage => 'Imatge';

  @override
  String get issuePronunciation => 'Pronúncia';

  @override
  String get issueMeaning => 'Significat / fets';

  @override
  String get issueOther => 'Altres';

  @override
  String get feedbackCommentHint => 'Què hi ha malament? (opcional)';

  @override
  String get feedbackSend => 'Envia per correu';

  @override
  String feedbackNoMailApp(String email) {
    return 'No hi ha cap aplicació de correu. L\'informe s\'ha copiat al porta-retalls; envia\'l a $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problema amb la targeta $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Baralla: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Targeta: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Idiomes: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Es mostra: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Estil: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Tipus de problema: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Per a: $email';
  }

  @override
  String get pronounce => 'Pronuncia';

  @override
  String get installVoice => 'Instal·la una veu';

  @override
  String noVoiceInstalled(String lang) {
    return 'No hi ha cap veu instal·lada per a «$lang». Afegeix-ne una a Configuració → Accessibilitat → Contingut parlat → Veus i torna-ho a provar.';
  }

  @override
  String get playPronunciation => 'Reprodueix la pronúncia';

  @override
  String get swipeNext => 'SEGÜENT';

  @override
  String get swipeBack => 'ENRERE';

  @override
  String get showTranslation => 'Mostra la traducció';

  @override
  String get showOriginal => 'Mostra l\'original';

  @override
  String get noCards => 'No hi ha targetes';

  @override
  String get deckHasNoCards => 'Aquesta baralla no té targetes.';

  @override
  String get flashcards => 'Targetes';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc =>
      'Fotografia nítida, la més propera a la realitat';

  @override
  String get styleInk => 'Pinzell i tinta';

  @override
  String get styleInkDesc => 'Pinzellades, paper nu, un sol accent de color';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Pastel sec sobre paper de color';

  @override
  String get styleWatercolor => 'Aquarel·la';

  @override
  String get styleWatercolorDesc =>
      'Aigades que s\'escampen i deixen veure el paper';

  @override
  String get styleFlag => 'Banderes';

  @override
  String get styleFlagDesc => 'Les banderes nacionals reals';

  @override
  String get stylePonyCartoon => 'Dibuixos animats';

  @override
  String get stylePonyCartoonDesc =>
      'Il·lustració acolorida de dibuixos animats';

  @override
  String get styleStorybook => 'Llibre de contes';

  @override
  String get styleStorybookDesc => 'Il·lustració suau de llibre';

  @override
  String get stylePonyWatercolor => 'Aquarel·la – suau';

  @override
  String get stylePonyWatercolorDesc => 'Pintura suau a l\'aquarel·la';

  @override
  String get stylePonyOil => 'Pintura a l\'oli';

  @override
  String get stylePonyOilDesc => 'Pinzellades gruixudes sobre tela';

  @override
  String get styleIllustriousOil => 'Oli – empastat';

  @override
  String get styleIllustriousOilDesc => 'Pintura espessa empastada, clarobscur';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Dibuix anime japonès';

  @override
  String get styleFlat => 'Vector pla';

  @override
  String get styleFlatDesc => 'Colors plans i formes netes';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Gravat japonès en fusta';

  @override
  String get styleMucha => 'Modernisme (Mucha)';

  @override
  String get styleMuchaDesc => 'Modernisme ornamental amb tocs daurats';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Pinzellades postimpressionistes en remolí';

  @override
  String get langAr => 'Àrab';

  @override
  String get langCs => 'Txec';

  @override
  String get langDe => 'Alemany';

  @override
  String get langEl => 'Grec';

  @override
  String get langEn => 'Anglès';

  @override
  String get langEs419 => 'Castellà';

  @override
  String get langFr => 'Francès';

  @override
  String get langHe => 'Hebreu';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonesi';

  @override
  String get langJa => 'Japonès';

  @override
  String get langKo => 'Coreà';

  @override
  String get langPtBR => 'Portuguès';

  @override
  String get langRu => 'Rus';

  @override
  String get langTr => 'Turc';

  @override
  String get langVi => 'Vietnamita';

  @override
  String get langZhCN => 'Xinès';
}
