// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Trgovina špilova';

  @override
  String get homeEmptyTitle => 'Još nema špilova';

  @override
  String get homeReorderHint =>
      'Dugo pritisnite špil i povucite ga da promijenite redoslijed';

  @override
  String get homeBrowseStore => 'Pregledaj trgovinu špilova';

  @override
  String get homeDownloadingDecks => 'Pripremamo vaše špilove…';

  @override
  String get badgeFree => 'Besplatno';

  @override
  String get badgeUnlocked => 'Otključano';

  @override
  String get badgePurchased => 'Kupljeno';

  @override
  String get badgePaidDeck => 'Plaćeni špil';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kartica',
      few: '$count kartice',
      one: '$count kartica',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards kartica',
      few: '$cards kartice',
      one: '$cards kartica',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs jezika',
      few: '$langs jezika',
      one: '$langs jezik',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return 'Znam: $count';
  }

  @override
  String legendLearning(int count) {
    return 'Učim: $count';
  }

  @override
  String legendUnknown(int count) {
    return 'Ne znam: $count';
  }

  @override
  String get storeTitle => 'Trgovina špilova';

  @override
  String get storeRestorePurchases => 'Vrati kupnje';

  @override
  String get storeSearchHint => 'Pretraži špilove…';

  @override
  String storeLoadError(String error) {
    return 'Špilovi se ne mogu učitati: $error';
  }

  @override
  String get storeNoDecks => 'Nema dostupnih špilova.';

  @override
  String get storeNothingFound => 'Ništa nije pronađeno.';

  @override
  String get retry => 'Pokušaj ponovno';

  @override
  String get buy => 'Kupi';

  @override
  String buyFor(String price) {
    return 'Kupi za $price';
  }

  @override
  String get add => 'Dodaj';

  @override
  String get addFree => 'Dodaj besplatno';

  @override
  String get back => 'Natrag';

  @override
  String get previous => 'Prethodna';

  @override
  String get next => 'Dalje';

  @override
  String get study => 'Uči';

  @override
  String get download => 'Preuzmi';

  @override
  String get confirmLanguagesLabel => 'Jezici';

  @override
  String get styleSectionTitle => 'Stil slika';

  @override
  String get confirmBuyNote =>
      'Kupnja otključava cijeli špil — sve jezike i sve stilove. Ova kombinacija bit će dodana na vaš početni zaslon.';

  @override
  String get confirmAddNote =>
      'Ova kombinacija bit će dodana na vaš početni zaslon. Drugi jezik ili stil možete dodati u bilo kojem trenutku.';

  @override
  String get purchaseFailedToStart => 'Kupnju nije bilo moguće pokrenuti.';

  @override
  String get addedToHome => 'Dodano na početni zaslon.';

  @override
  String get downloadFailed => 'Preuzimanje nije uspjelo. Pokušajte ponovno.';

  @override
  String get deckNotPurchased => 'Ovaj špil nije kupljen.';

  @override
  String downloading(int percent) {
    return 'Preuzimanje… $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktivnih',
      few: '$count aktivne',
      one: '$count aktivna',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Znam';

  @override
  String get pickerLearning => 'Učim';

  @override
  String get reportIssue => 'Prijavi problem';

  @override
  String get issueTranslation => 'Prijevod';

  @override
  String get issueImage => 'Slika';

  @override
  String get issuePronunciation => 'Izgovor';

  @override
  String get issueMeaning => 'Značenje / činjenice';

  @override
  String get issueOther => 'Ostalo';

  @override
  String get feedbackCommentHint => 'Što nije u redu? (neobavezno)';

  @override
  String get feedbackSend => 'Pošalji e-poštom';

  @override
  String feedbackNoMailApp(String email) {
    return 'Nema dostupne aplikacije za e-poštu. Prijava je kopirana u međuspremnik — pošaljite je na $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problem s karticom $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Špil: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kartica: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Jezici: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Prikazano: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Stil: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Vrsta problema: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Prima: $email';
  }

  @override
  String get pronounce => 'Izgovori';

  @override
  String get installVoice => 'Instaliraj glas';

  @override
  String noVoiceInstalled(String lang) {
    return 'Nije instaliran glas za „$lang”. Dodajte ga u Postavkama → Pristupačnost → Izgovoreni sadržaj → Glasovi i pokušajte ponovno.';
  }

  @override
  String get playPronunciation => 'Reproduciraj izgovor';

  @override
  String get swipeNext => 'DALJE';

  @override
  String get swipeBack => 'NATRAG';

  @override
  String get showTranslation => 'Prikaži prijevod';

  @override
  String get showOriginal => 'Prikaži izvornik';

  @override
  String get noCards => 'Nema kartica';

  @override
  String get deckHasNoCards => 'Ovaj špil nema kartica.';

  @override
  String get flashcards => 'Kartice za učenje';

  @override
  String get stylePhoto => 'Fotografija';

  @override
  String get stylePhotoDesc => 'Oštra fotografija, najbliža stvarnosti';

  @override
  String get styleInk => 'Kist i tuš';

  @override
  String get styleInkDesc => 'Potezi kistom, goli papir, jedan naglasak u boji';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Suhi pastel na toniranom papiru';

  @override
  String get styleWatercolor => 'Akvarel';

  @override
  String get styleWatercolorDesc => 'Razlivene mrlje kroz koje se nazire papir';

  @override
  String get styleFlag => 'Zastave';

  @override
  String get styleFlagDesc => 'Prave državne zastave';

  @override
  String get stylePonyCartoon => 'Crtić';

  @override
  String get stylePonyCartoonDesc => 'Šarena crtana ilustracija';

  @override
  String get styleStorybook => 'Slikovnica';

  @override
  String get styleStorybookDesc => 'Nježna knjiška ilustracija';

  @override
  String get stylePonyWatercolor => 'Akvarel – nježni';

  @override
  String get stylePonyWatercolorDesc => 'Nježna akvarelna slika';

  @override
  String get stylePonyOil => 'Uljana slika';

  @override
  String get stylePonyOilDesc => 'Debeli potezi kistom na platnu';

  @override
  String get styleIllustriousOil => 'Ulje – impasto';

  @override
  String get styleIllustriousOilDesc => 'Gusti impasto namaz, chiaroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japanski anime crtež';

  @override
  String get styleFlat => 'Plosnati vektor';

  @override
  String get styleFlatDesc => 'Plosnate boje i čisti oblici';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japanski drvorez';

  @override
  String get styleMucha => 'Secesija (Mucha)';

  @override
  String get styleMuchaDesc => 'Ornamentalna secesija sa zlatnim naglascima';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Postimpresionistički vrtložni potezi';

  @override
  String get langAr => 'Arapski';

  @override
  String get langCs => 'Češki';

  @override
  String get langDe => 'Njemački';

  @override
  String get langEl => 'Grčki';

  @override
  String get langEn => 'Engleski';

  @override
  String get langEs419 => 'Španjolski';

  @override
  String get langFr => 'Francuski';

  @override
  String get langHe => 'Hebrejski';

  @override
  String get langHi => 'Hindski';

  @override
  String get langId => 'Indonezijski';

  @override
  String get langJa => 'Japanski';

  @override
  String get langKo => 'Korejski';

  @override
  String get langPtBR => 'Portugalski';

  @override
  String get langRu => 'Ruski';

  @override
  String get langTr => 'Turski';

  @override
  String get langVi => 'Vijetnamski';

  @override
  String get langZhCN => 'Kineski';
}
