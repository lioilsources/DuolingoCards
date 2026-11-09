// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Kortstokkbutikk';

  @override
  String get homeEmptyTitle => 'Ingen kortstokker ennå';

  @override
  String get homeReorderHint =>
      'Hold inne en kortstokk og dra den for å endre rekkefølgen';

  @override
  String get homeBrowseStore => 'Se kortstokkbutikken';

  @override
  String get homeDownloadingDecks => 'Gjør klar kortstokkene dine…';

  @override
  String get badgeFree => 'Gratis';

  @override
  String get badgeUnlocked => 'Låst opp';

  @override
  String get badgePurchased => 'Kjøpt';

  @override
  String get badgePaidDeck => 'Betalt kortstokk';

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
      other: '$langs språk',
      one: '1 språk',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count kan';
  }

  @override
  String legendLearning(int count) {
    return '$count lærer';
  }

  @override
  String legendUnknown(int count) {
    return '$count ukjente';
  }

  @override
  String get storeTitle => 'Kortstokkbutikk';

  @override
  String get storeRestorePurchases => 'Gjenopprett kjøp';

  @override
  String get storeSearchHint => 'Søk i kortstokker…';

  @override
  String storeLoadError(String error) {
    return 'Kunne ikke laste inn kortstokkene: $error';
  }

  @override
  String get storeNoDecks => 'Ingen kortstokker tilgjengelig.';

  @override
  String get storeNothingFound => 'Fant ingenting.';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get buy => 'Kjøp';

  @override
  String buyFor(String price) {
    return 'Kjøp for $price';
  }

  @override
  String get add => 'Legg til';

  @override
  String get addFree => 'Legg til gratis';

  @override
  String get back => 'Tilbake';

  @override
  String get previous => 'Forrige';

  @override
  String get next => 'Neste';

  @override
  String get study => 'Øv';

  @override
  String get download => 'Last ned';

  @override
  String get confirmLanguagesLabel => 'Språk';

  @override
  String get styleSectionTitle => 'Bildestil';

  @override
  String get confirmBuyNote =>
      'Kjøpet låser opp hele kortstokken — alle språk og alle stiler. Denne kombinasjonen legges til på startskjermen din.';

  @override
  String get confirmAddNote =>
      'Denne kombinasjonen legges til på startskjermen din. Du kan når som helst legge til et annet språk eller en annen stil.';

  @override
  String get purchaseFailedToStart => 'Kjøpet kunne ikke startes.';

  @override
  String get addedToHome => 'Lagt til på startskjermen.';

  @override
  String get downloadFailed => 'Nedlastingen mislyktes. Prøv igjen.';

  @override
  String get deckNotPurchased => 'Denne kortstokken er ikke kjøpt.';

  @override
  String downloading(int percent) {
    return 'Laster ned… $percent %';
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
  String get pickerIKnow => 'Kan';

  @override
  String get pickerLearning => 'Lærer';

  @override
  String get reportIssue => 'Rapporter et problem';

  @override
  String get issueTranslation => 'Oversettelse';

  @override
  String get issueImage => 'Bilde';

  @override
  String get issuePronunciation => 'Uttale';

  @override
  String get issueMeaning => 'Betydning / fakta';

  @override
  String get issueOther => 'Annet';

  @override
  String get feedbackCommentHint => 'Hva er feil? (valgfritt)';

  @override
  String get feedbackSend => 'Send på e-post';

  @override
  String feedbackNoMailApp(String email) {
    return 'Ingen e-postapp er tilgjengelig. Rapporten er kopiert til utklippstavlen — send den til $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problem med kort $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Kortstokk: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kort: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Språk: $l1 → $l2';
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
  String get pronounce => 'Uttal';

  @override
  String get installVoice => 'Installer stemme';

  @override
  String noVoiceInstalled(String lang) {
    return 'Ingen stemme for «$lang» er installert. Legg til en under Innstillinger → Tilgjengelighet → Opplest innhold → Stemmer, og prøv igjen.';
  }

  @override
  String get playPronunciation => 'Spill av uttale';

  @override
  String get swipeNext => 'NESTE';

  @override
  String get swipeBack => 'TILBAKE';

  @override
  String get showTranslation => 'Vis oversettelse';

  @override
  String get showOriginal => 'Vis original';

  @override
  String get noCards => 'Ingen kort';

  @override
  String get deckHasNoCards => 'Denne kortstokken har ingen kort.';

  @override
  String get flashcards => 'Gloser';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc => 'Skarpt fotografi, nærmest virkeligheten';

  @override
  String get styleInk => 'Pensel og tusj';

  @override
  String get styleInkDesc => 'Penselstrøk, bart papir, én fargeaksent';

  @override
  String get stylePastel => 'Pastell';

  @override
  String get stylePastelDesc => 'Tørrpastell på tonet papir';

  @override
  String get styleWatercolor => 'Akvarell';

  @override
  String get styleWatercolorDesc =>
      'Flytende laseringer, papiret skinner gjennom';

  @override
  String get styleFlag => 'Flagg';

  @override
  String get styleFlagDesc => 'De ekte nasjonalflaggene';

  @override
  String get stylePonyCartoon => 'Tegneserie';

  @override
  String get stylePonyCartoonDesc => 'Fargerik tegneserieillustrasjon';

  @override
  String get styleStorybook => 'Bildebok';

  @override
  String get styleStorybookDesc => 'Myk bokillustrasjon';

  @override
  String get stylePonyWatercolor => 'Akvarell – myk';

  @override
  String get stylePonyWatercolorDesc => 'Myk akvarellmaleri';

  @override
  String get stylePonyOil => 'Oljemaleri';

  @override
  String get stylePonyOilDesc => 'Tykke penselstrøk på lerret';

  @override
  String get styleIllustriousOil => 'Olje – impasto';

  @override
  String get styleIllustriousOilDesc => 'Tykk impastomaling, chiaroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japansk animetegning';

  @override
  String get styleFlat => 'Flat vektor';

  @override
  String get styleFlatDesc => 'Flate farger og rene former';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japansk tresnitt';

  @override
  String get styleMucha => 'Jugend (Mucha)';

  @override
  String get styleMuchaDesc => 'Ornamental jugendstil med gullaksenter';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Postimpresjonistiske virvlende strøk';

  @override
  String get langAr => 'Arabisk';

  @override
  String get langCs => 'Tsjekkisk';

  @override
  String get langDe => 'Tysk';

  @override
  String get langEl => 'Gresk';

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
