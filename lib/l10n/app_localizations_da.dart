// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Butik med kortsæt';

  @override
  String get homeEmptyTitle => 'Ingen kortsæt endnu';

  @override
  String get homeReorderHint =>
      'Hold fingeren på et kortsæt, og træk det for at ændre rækkefølgen';

  @override
  String get homeBrowseStore => 'Gå til butikken med kortsæt';

  @override
  String get homeDownloadingDecks => 'Gør dine kortsæt klar…';

  @override
  String get badgeFree => 'Gratis';

  @override
  String get badgeUnlocked => 'Låst op';

  @override
  String get badgePurchased => 'Købt';

  @override
  String get badgePaidDeck => 'Betalt kortsæt';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kort',
      one: '1 kort',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards kort',
      one: '1 kort',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs sprog',
      one: '1 sprog',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count kendte';
  }

  @override
  String legendLearning(int count) {
    return '$count under indlæring';
  }

  @override
  String legendUnknown(int count) {
    return '$count ukendte';
  }

  @override
  String get storeTitle => 'Butik med kortsæt';

  @override
  String get storeRestorePurchases => 'Gendan køb';

  @override
  String get storeSearchHint => 'Søg i kortsæt…';

  @override
  String storeLoadError(String error) {
    return 'Kortsættene kunne ikke indlæses: $error';
  }

  @override
  String get storeNoDecks => 'Ingen kortsæt tilgængelige.';

  @override
  String get storeNothingFound => 'Intet fundet.';

  @override
  String get retry => 'Prøv igen';

  @override
  String get buy => 'Køb';

  @override
  String buyFor(String price) {
    return 'Køb for $price';
  }

  @override
  String get add => 'Tilføj';

  @override
  String get addFree => 'Tilføj gratis';

  @override
  String get back => 'Tilbage';

  @override
  String get previous => 'Forrige';

  @override
  String get next => 'Næste';

  @override
  String get study => 'Lær';

  @override
  String get download => 'Hent';

  @override
  String get confirmLanguagesLabel => 'Sprog';

  @override
  String get styleSectionTitle => 'Billedstil';

  @override
  String get confirmBuyNote =>
      'Købet låser hele kortsættet op — alle sprog og alle stilarter. Denne kombination føjes til din startskærm.';

  @override
  String get confirmAddNote =>
      'Denne kombination føjes til din startskærm. Du kan til enhver tid tilføje et andet sprog eller en anden stil.';

  @override
  String get purchaseFailedToStart => 'Købet kunne ikke startes.';

  @override
  String get addedToHome => 'Føjet til din startskærm.';

  @override
  String get downloadFailed => 'Overførslen mislykkedes. Prøv igen.';

  @override
  String get deckNotPurchased => 'Dette kortsæt er ikke købt.';

  @override
  String downloading(int percent) {
    return 'Henter… $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktive',
      one: '1 aktiv',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Kan det';

  @override
  String get pickerLearning => 'Lærer det';

  @override
  String get reportIssue => 'Rapportér et problem';

  @override
  String get issueTranslation => 'Oversættelse';

  @override
  String get issueImage => 'Billede';

  @override
  String get issuePronunciation => 'Udtale';

  @override
  String get issueMeaning => 'Betydning / fakta';

  @override
  String get issueOther => 'Andet';

  @override
  String get feedbackCommentHint => 'Hvad er galt? (valgfrit)';

  @override
  String get feedbackSend => 'Send via e-mail';

  @override
  String feedbackNoMailApp(String email) {
    return 'Der er ingen mailapp. Rapporten er kopieret til udklipsholderen — send den til $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problem med kort $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Kortsæt: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kort: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Sprog: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Vist: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Stil: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Problemtype: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Til: $email';
  }

  @override
  String get pronounce => 'Udtal';

  @override
  String get installVoice => 'Installer stemme';

  @override
  String noVoiceInstalled(String lang) {
    return 'Der er ingen stemme installeret til \"$lang\". Tilføj en under Indstillinger → Tilgængelighed → Oplæst indhold → Stemmer, og prøv igen.';
  }

  @override
  String get playPronunciation => 'Afspil udtale';

  @override
  String get swipeNext => 'NÆSTE';

  @override
  String get swipeBack => 'TILBAGE';

  @override
  String get showTranslation => 'Vis oversættelse';

  @override
  String get showOriginal => 'Vis original';

  @override
  String get noCards => 'Ingen kort';

  @override
  String get deckHasNoCards => 'Dette kortsæt har ingen kort.';

  @override
  String get flashcards => 'Flashcards';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc => 'Skarpt fotografi, tættest på virkeligheden';

  @override
  String get styleInk => 'Pensel og tusch';

  @override
  String get styleInkDesc => 'Penselstrøg, bart papir, én farveaccent';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Tør pastel på tonet papir';

  @override
  String get styleWatercolor => 'Akvarel';

  @override
  String get styleWatercolorDesc =>
      'Flydende laveringer, papiret skinner igennem';

  @override
  String get styleFlag => 'Flag';

  @override
  String get styleFlagDesc => 'De rigtige nationalflag';

  @override
  String get stylePonyCartoon => 'Tegneserie';

  @override
  String get stylePonyCartoonDesc => 'Farverig tegneserieillustration';

  @override
  String get styleStorybook => 'Billedbog';

  @override
  String get styleStorybookDesc => 'Blød bogillustration';

  @override
  String get stylePonyWatercolor => 'Akvarel – blød';

  @override
  String get stylePonyWatercolorDesc => 'Blødt akvarelmaleri';

  @override
  String get stylePonyOil => 'Oliemaleri';

  @override
  String get stylePonyOilDesc => 'Tykke penselstrøg på lærred';

  @override
  String get styleIllustriousOil => 'Olie – impasto';

  @override
  String get styleIllustriousOilDesc => 'Tyk impastomaling, chiaroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japansk animetegning';

  @override
  String get styleFlat => 'Flad vektor';

  @override
  String get styleFlatDesc => 'Flade farver og rene former';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japansk træsnit';

  @override
  String get styleMucha => 'Art nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Ornamental art nouveau med guldaccenter';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Postimpressionistiske hvirvlende strøg';

  @override
  String get langAr => 'Arabisk';

  @override
  String get langCs => 'Tjekkisk';

  @override
  String get langDe => 'Tysk';

  @override
  String get langEl => 'Græsk';

  @override
  String get langEn => 'Engelsk';

  @override
  String get langEs419 => 'Spansk';

  @override
  String get langFr => 'Fransk';

  @override
  String get langHe => 'Hebraisk';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonesisk';

  @override
  String get langJa => 'Japansk';

  @override
  String get langKo => 'Koreansk';

  @override
  String get langPtBR => 'Portugisisk';

  @override
  String get langRu => 'Russisk';

  @override
  String get langTr => 'Tyrkisk';

  @override
  String get langVi => 'Vietnamesisk';

  @override
  String get langZhCN => 'Kinesisk';
}
