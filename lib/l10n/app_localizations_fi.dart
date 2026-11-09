// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Pakkakauppa';

  @override
  String get homeEmptyTitle => 'Ei vielä pakkoja';

  @override
  String get homeReorderHint =>
      'Paina pakkaa pitkään ja vedä se uuteen kohtaan';

  @override
  String get homeBrowseStore => 'Selaa pakkakauppaa';

  @override
  String get homeDownloadingDecks => 'Valmistellaan pakkojasi…';

  @override
  String get badgeFree => 'Ilmainen';

  @override
  String get badgeUnlocked => 'Avattu';

  @override
  String get badgePurchased => 'Ostettu';

  @override
  String get badgePaidDeck => 'Maksullinen pakka';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count korttia',
      one: '1 kortti',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards korttia',
      one: '1 kortti',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs kieltä',
      one: '1 kieli',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count osattu';
  }

  @override
  String legendLearning(int count) {
    return '$count opeteltavana';
  }

  @override
  String legendUnknown(int count) {
    return '$count tuntematonta';
  }

  @override
  String get storeTitle => 'Pakkakauppa';

  @override
  String get storeRestorePurchases => 'Palauta ostot';

  @override
  String get storeSearchHint => 'Hae pakkoja…';

  @override
  String storeLoadError(String error) {
    return 'Pakkojen lataus epäonnistui: $error';
  }

  @override
  String get storeNoDecks => 'Pakkoja ei ole saatavilla.';

  @override
  String get storeNothingFound => 'Mitään ei löytynyt.';

  @override
  String get retry => 'Yritä uudelleen';

  @override
  String get buy => 'Osta';

  @override
  String buyFor(String price) {
    return 'Osta hintaan $price';
  }

  @override
  String get add => 'Lisää';

  @override
  String get addFree => 'Lisää ilmaiseksi';

  @override
  String get back => 'Takaisin';

  @override
  String get previous => 'Edellinen';

  @override
  String get next => 'Seuraava';

  @override
  String get study => 'Opiskele';

  @override
  String get download => 'Lataa';

  @override
  String get confirmLanguagesLabel => 'Kielet';

  @override
  String get styleSectionTitle => 'Kuvatyyli';

  @override
  String get confirmBuyNote =>
      'Ostos avaa koko pakan — kaikki kielet ja kaikki tyylit. Tämä yhdistelmä lisätään aloitusnäytöllesi.';

  @override
  String get confirmAddNote =>
      'Tämä yhdistelmä lisätään aloitusnäytöllesi. Voit lisätä toisen kielen tai tyylin milloin tahansa.';

  @override
  String get purchaseFailedToStart => 'Ostoa ei voitu aloittaa.';

  @override
  String get addedToHome => 'Lisätty aloitusnäytölle.';

  @override
  String get downloadFailed => 'Lataus epäonnistui. Yritä uudelleen.';

  @override
  String get deckNotPurchased => 'Tätä pakkaa ei ole ostettu.';

  @override
  String downloading(int percent) {
    return 'Ladataan… $percent %';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count käytössä',
      one: '1 käytössä',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Osaan';

  @override
  String get pickerLearning => 'Opettelen';

  @override
  String get reportIssue => 'Ilmoita ongelmasta';

  @override
  String get issueTranslation => 'Käännös';

  @override
  String get issueImage => 'Kuva';

  @override
  String get issuePronunciation => 'Ääntäminen';

  @override
  String get issueMeaning => 'Merkitys / faktat';

  @override
  String get issueOther => 'Muu';

  @override
  String get feedbackCommentHint => 'Mikä on vialla? (valinnainen)';

  @override
  String get feedbackSend => 'Lähetä sähköpostilla';

  @override
  String feedbackNoMailApp(String email) {
    return 'Sähköpostisovellusta ei ole saatavilla. Ilmoitus kopioitiin leikepöydälle — lähetä se osoitteeseen $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Ongelma kortissa $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Pakka: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kortti: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Kielet: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Näytetty: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Tyyli: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Ongelman tyyppi: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Vastaanottaja: $email';
  }

  @override
  String get pronounce => 'Äännä';

  @override
  String get installVoice => 'Asenna ääni';

  @override
  String noVoiceInstalled(String lang) {
    return 'Kielelle ”$lang” ei ole asennettu ääntä. Lisää ääni kohdassa Asetukset → Käyttöapu → Puhuttu sisältö → Äänet ja yritä uudelleen.';
  }

  @override
  String get playPronunciation => 'Toista ääntäminen';

  @override
  String get swipeNext => 'SEURAAVA';

  @override
  String get swipeBack => 'TAKAISIN';

  @override
  String get showTranslation => 'Näytä käännös';

  @override
  String get showOriginal => 'Näytä alkuperäinen';

  @override
  String get noCards => 'Ei kortteja';

  @override
  String get deckHasNoCards => 'Tässä pakassa ei ole kortteja.';

  @override
  String get flashcards => 'Sanakortit';

  @override
  String get stylePhoto => 'Valokuva';

  @override
  String get stylePhotoDesc => 'Terävä valokuva, lähimpänä todellisuutta';

  @override
  String get styleInk => 'Sivellin ja tussi';

  @override
  String get styleInkDesc =>
      'Siveltimenvedot, paljas paperi, yksi väriaksentti';

  @override
  String get stylePastel => 'Pastelli';

  @override
  String get stylePastelDesc => 'Kuivapastelli sävytetyllä paperilla';

  @override
  String get styleWatercolor => 'Vesiväri';

  @override
  String get styleWatercolorDesc =>
      'Leviävät laveeraukset, paperi kuultaa läpi';

  @override
  String get styleFlag => 'Liput';

  @override
  String get styleFlagDesc => 'Oikeat kansalliset liput';

  @override
  String get stylePonyCartoon => 'Piirretty';

  @override
  String get stylePonyCartoonDesc => 'Värikäs piirroskuvitus';

  @override
  String get styleStorybook => 'Satukirja';

  @override
  String get styleStorybookDesc => 'Pehmeä kirjakuvitus';

  @override
  String get stylePonyWatercolor => 'Vesiväri – pehmeä';

  @override
  String get stylePonyWatercolorDesc => 'Pehmeä vesivärimaalaus';

  @override
  String get stylePonyOil => 'Öljymaalaus';

  @override
  String get stylePonyOilDesc => 'Paksut siveltimenvedot kankaalla';

  @override
  String get styleIllustriousOil => 'Öljy – impasto';

  @override
  String get styleIllustriousOilDesc => 'Paksu impastomaali, chiaroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japanilainen animepiirros';

  @override
  String get styleFlat => 'Litteä vektori';

  @override
  String get styleFlatDesc => 'Tasaiset värit ja selkeät muodot';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japanilainen puupiirros';

  @override
  String get styleMucha => 'Jugend (Mucha)';

  @override
  String get styleMuchaDesc => 'Koristeellinen jugend kultaisin korostuksin';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Postimpressionistiset pyörteiset vedot';

  @override
  String get langAr => 'Arabia';

  @override
  String get langCs => 'Tšekki';

  @override
  String get langDe => 'Saksa';

  @override
  String get langEl => 'Kreikka';

  @override
  String get langEn => 'Englanti';

  @override
  String get langEs419 => 'Espanja';

  @override
  String get langFr => 'Ranska';

  @override
  String get langHe => 'Heprea';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonesia';

  @override
  String get langJa => 'Japani';

  @override
  String get langKo => 'Korea';

  @override
  String get langPtBR => 'Portugali';

  @override
  String get langRu => 'Venäjä';

  @override
  String get langTr => 'Turkki';

  @override
  String get langVi => 'Vietnam';

  @override
  String get langZhCN => 'Kiina';
}
