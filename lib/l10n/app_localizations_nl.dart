// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Kaartenwinkel';

  @override
  String get homeEmptyTitle => 'Nog geen sets';

  @override
  String get homeReorderHint =>
      'Houd een set ingedrukt en sleep om de volgorde te wijzigen';

  @override
  String get homeBrowseStore => 'Bekijk de kaartenwinkel';

  @override
  String get homeDownloadingDecks => 'Je sets worden klaargezet…';

  @override
  String get badgeFree => 'Gratis';

  @override
  String get badgeUnlocked => 'Ontgrendeld';

  @override
  String get badgePurchased => 'Gekocht';

  @override
  String get badgePaidDeck => 'Betaalde set';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kaarten',
      one: '1 kaart',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards kaarten',
      one: '1 kaart',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs talen',
      one: '1 taal',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count bekend';
  }

  @override
  String legendLearning(int count) {
    return '$count aan het leren';
  }

  @override
  String legendUnknown(int count) {
    return '$count onbekend';
  }

  @override
  String get storeTitle => 'Kaartenwinkel';

  @override
  String get storeRestorePurchases => 'Aankopen herstellen';

  @override
  String get storeSearchHint => 'Sets zoeken…';

  @override
  String storeLoadError(String error) {
    return 'Kan sets niet laden: $error';
  }

  @override
  String get storeNoDecks => 'Geen sets beschikbaar.';

  @override
  String get storeNothingFound => 'Niets gevonden.';

  @override
  String get retry => 'Opnieuw';

  @override
  String get buy => 'Kopen';

  @override
  String buyFor(String price) {
    return 'Kopen voor $price';
  }

  @override
  String get add => 'Toevoegen';

  @override
  String get addFree => 'Gratis toevoegen';

  @override
  String get back => 'Terug';

  @override
  String get previous => 'Vorige';

  @override
  String get next => 'Volgende';

  @override
  String get study => 'Leren';

  @override
  String get download => 'Downloaden';

  @override
  String get confirmLanguagesLabel => 'Talen';

  @override
  String get styleSectionTitle => 'Afbeeldingsstijl';

  @override
  String get confirmBuyNote =>
      'Met de aankoop ontgrendel je de hele set — alle talen en alle stijlen. Deze combinatie wordt aan je beginscherm toegevoegd.';

  @override
  String get confirmAddNote =>
      'Deze combinatie wordt aan je beginscherm toegevoegd. Je kunt altijd een andere taal of stijl toevoegen.';

  @override
  String get purchaseFailedToStart => 'De aankoop kon niet worden gestart.';

  @override
  String get addedToHome => 'Toegevoegd aan je beginscherm.';

  @override
  String get downloadFailed => 'Downloaden mislukt. Probeer het opnieuw.';

  @override
  String get deckNotPurchased => 'Deze set is niet gekocht.';

  @override
  String downloading(int percent) {
    return 'Downloaden… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actief',
      one: '1 actief',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Ken ik';

  @override
  String get pickerLearning => 'Aan het leren';

  @override
  String get reportIssue => 'Probleem melden';

  @override
  String get issueTranslation => 'Vertaling';

  @override
  String get issueImage => 'Afbeelding';

  @override
  String get issuePronunciation => 'Uitspraak';

  @override
  String get issueMeaning => 'Betekenis / feiten';

  @override
  String get issueOther => 'Overig';

  @override
  String get feedbackCommentHint => 'Wat is er mis? (optioneel)';

  @override
  String get feedbackSend => 'Versturen per e-mail';

  @override
  String feedbackNoMailApp(String email) {
    return 'Er is geen e-mailapp beschikbaar. De melding is naar het klembord gekopieerd — stuur hem naar $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Probleem met kaart $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Set: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kaart: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Talen: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Getoond: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Stijl: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Soort probleem: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Aan: $email';
  }

  @override
  String get pronounce => 'Uitspreken';

  @override
  String get installVoice => 'Stem installeren';

  @override
  String noVoiceInstalled(String lang) {
    return 'Er is geen stem voor ‘$lang’ geïnstalleerd. Voeg er een toe via Instellingen → Toegankelijkheid → Gesproken materiaal → Stemmen en probeer het opnieuw.';
  }

  @override
  String get playPronunciation => 'Uitspraak afspelen';

  @override
  String get swipeNext => 'VOLGENDE';

  @override
  String get swipeBack => 'TERUG';

  @override
  String get showTranslation => 'Vertaling tonen';

  @override
  String get showOriginal => 'Origineel tonen';

  @override
  String get noCards => 'Geen kaarten';

  @override
  String get deckHasNoCards => 'Deze set heeft geen kaarten.';

  @override
  String get flashcards => 'Flitskaarten';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc => 'Scherpe foto, het dichtst bij de werkelijkheid';

  @override
  String get styleInk => 'Penseel en inkt';

  @override
  String get styleInkDesc => 'Penseelstreken, kaal papier, één kleuraccent';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Droog pastel op getint papier';

  @override
  String get styleWatercolor => 'Aquarel';

  @override
  String get styleWatercolorDesc =>
      'Vloeiende wassingen, papier dat doorschemert';

  @override
  String get styleFlag => 'Vlaggen';

  @override
  String get styleFlagDesc => 'De echte nationale vlaggen';

  @override
  String get stylePonyCartoon => 'Cartoon';

  @override
  String get stylePonyCartoonDesc => 'Kleurrijke cartoonillustratie';

  @override
  String get styleStorybook => 'Prentenboek';

  @override
  String get styleStorybookDesc => 'Zachte boekillustratie';

  @override
  String get stylePonyWatercolor => 'Aquarel – zacht';

  @override
  String get stylePonyWatercolorDesc => 'Zacht aquarelschilderij';

  @override
  String get stylePonyOil => 'Olieverf';

  @override
  String get stylePonyOilDesc => 'Dikke penseelstreken op doek';

  @override
  String get styleIllustriousOil => 'Olie – impasto';

  @override
  String get styleIllustriousOilDesc => 'Dikke impastoverf, clair-obscur';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japanse animetekening';

  @override
  String get styleFlat => 'Platte vector';

  @override
  String get styleFlatDesc => 'Vlakke kleuren en strakke vormen';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japanse houtsnede';

  @override
  String get styleMucha => 'Art nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Sierlijke art nouveau met gouden accenten';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Postimpressionistische wervelende streken';

  @override
  String get langAr => 'Arabisch';

  @override
  String get langCs => 'Tsjechisch';

  @override
  String get langDe => 'Duits';

  @override
  String get langEl => 'Grieks';

  @override
  String get langEn => 'Engels';

  @override
  String get langEs419 => 'Spaans';

  @override
  String get langFr => 'Frans';

  @override
  String get langHe => 'Hebreeuws';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonesisch';

  @override
  String get langJa => 'Japans';

  @override
  String get langKo => 'Koreaans';

  @override
  String get langPtBR => 'Portugees';

  @override
  String get langRu => 'Russisch';

  @override
  String get langTr => 'Turks';

  @override
  String get langVi => 'Vietnamees';

  @override
  String get langZhCN => 'Chinees';
}
