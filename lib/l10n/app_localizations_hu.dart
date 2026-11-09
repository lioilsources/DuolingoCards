// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Pakliáruház';

  @override
  String get homeEmptyTitle => 'Még nincsenek paklik';

  @override
  String get homeReorderHint =>
      'Tarts lenyomva egy paklit, és húzd át a sorrend módosításához';

  @override
  String get homeBrowseStore => 'Pakliáruház megnyitása';

  @override
  String get homeDownloadingDecks => 'Előkészítjük a paklijaidat…';

  @override
  String get badgeFree => 'Ingyenes';

  @override
  String get badgeUnlocked => 'Feloldva';

  @override
  String get badgePurchased => 'Megvásárolva';

  @override
  String get badgePaidDeck => 'Fizetős pakli';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kártya',
      one: '1 kártya',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards kártya',
      one: '1 kártya',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs nyelv',
      one: '1 nyelv',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count ismert';
  }

  @override
  String legendLearning(int count) {
    return '$count tanulás alatt';
  }

  @override
  String legendUnknown(int count) {
    return '$count ismeretlen';
  }

  @override
  String get storeTitle => 'Pakliáruház';

  @override
  String get storeRestorePurchases => 'Vásárlások visszaállítása';

  @override
  String get storeSearchHint => 'Paklik keresése…';

  @override
  String storeLoadError(String error) {
    return 'Nem sikerült betölteni a paklikat: $error';
  }

  @override
  String get storeNoDecks => 'Nincs elérhető pakli.';

  @override
  String get storeNothingFound => 'Nincs találat.';

  @override
  String get retry => 'Újra';

  @override
  String get buy => 'Megveszem';

  @override
  String buyFor(String price) {
    return 'Megveszem: $price';
  }

  @override
  String get add => 'Hozzáadás';

  @override
  String get addFree => 'Hozzáadás ingyen';

  @override
  String get back => 'Vissza';

  @override
  String get previous => 'Előző';

  @override
  String get next => 'Tovább';

  @override
  String get study => 'Tanulás';

  @override
  String get download => 'Letöltés';

  @override
  String get confirmLanguagesLabel => 'Nyelvek';

  @override
  String get styleSectionTitle => 'Képstílus';

  @override
  String get confirmBuyNote =>
      'A vásárlás az egész paklit feloldja — minden nyelvet és minden stílust. Ez a kombináció felkerül a kezdőképernyődre.';

  @override
  String get confirmAddNote =>
      'Ez a kombináció felkerül a kezdőképernyődre. Bármikor hozzáadhatsz másik nyelvet vagy stílust.';

  @override
  String get purchaseFailedToStart => 'A vásárlást nem sikerült elindítani.';

  @override
  String get addedToHome => 'Hozzáadva a kezdőképernyőhöz.';

  @override
  String get downloadFailed => 'A letöltés nem sikerült. Próbáld újra.';

  @override
  String get deckNotPurchased => 'Ezt a paklit még nem vásároltad meg.';

  @override
  String downloading(int percent) {
    return 'Letöltés… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktív',
      one: '1 aktív',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Tudom';

  @override
  String get pickerLearning => 'Tanulom';

  @override
  String get reportIssue => 'Hiba jelentése';

  @override
  String get issueTranslation => 'Fordítás';

  @override
  String get issueImage => 'Kép';

  @override
  String get issuePronunciation => 'Kiejtés';

  @override
  String get issueMeaning => 'Jelentés / tények';

  @override
  String get issueOther => 'Egyéb';

  @override
  String get feedbackCommentHint => 'Mi a hiba? (nem kötelező)';

  @override
  String get feedbackSend => 'Küldés e-mailben';

  @override
  String feedbackNoMailApp(String email) {
    return 'Nincs elérhető levelezőalkalmazás. A jelentést a vágólapra másoltuk — küldd el ide: $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Hiba a(z) $key kártyán ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Pakli: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kártya: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Nyelvek: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Megjelenítve: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Stílus: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Hiba típusa: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Címzett: $email';
  }

  @override
  String get pronounce => 'Kiejtés';

  @override
  String get installVoice => 'Hang telepítése';

  @override
  String noVoiceInstalled(String lang) {
    return 'Nincs telepítve hang ehhez: „$lang”. Adj hozzá egyet a Beállítások → Kisegítő lehetőségek → Felolvasott tartalom → Hangok menüben, majd próbáld újra.';
  }

  @override
  String get playPronunciation => 'Kiejtés lejátszása';

  @override
  String get swipeNext => 'TOVÁBB';

  @override
  String get swipeBack => 'VISSZA';

  @override
  String get showTranslation => 'Fordítás mutatása';

  @override
  String get showOriginal => 'Eredeti mutatása';

  @override
  String get noCards => 'Nincsenek kártyák';

  @override
  String get deckHasNoCards => 'Ebben a pakliban nincsenek kártyák.';

  @override
  String get flashcards => 'Szókártyák';

  @override
  String get stylePhoto => 'Fotó';

  @override
  String get stylePhotoDesc => 'Éles fénykép, a valósághoz legközelebb';

  @override
  String get styleInk => 'Ecset és tus';

  @override
  String get styleInkDesc =>
      'Ecsetvonások, üres papír, egyetlen színes kiemelés';

  @override
  String get stylePastel => 'Pasztell';

  @override
  String get stylePastelDesc => 'Száraz pasztell színezett papíron';

  @override
  String get styleWatercolor => 'Akvarell';

  @override
  String get styleWatercolorDesc => 'Szétfutó foltok, átsejlő papír';

  @override
  String get styleFlag => 'Zászlók';

  @override
  String get styleFlagDesc => 'Valódi nemzeti zászlók';

  @override
  String get stylePonyCartoon => 'Rajzfilm';

  @override
  String get stylePonyCartoonDesc => 'Színes rajzfilmes illusztráció';

  @override
  String get styleStorybook => 'Mesekönyv';

  @override
  String get styleStorybookDesc => 'Lágy könyvillusztráció';

  @override
  String get stylePonyWatercolor => 'Akvarell – lágy';

  @override
  String get stylePonyWatercolorDesc => 'Lágy akvarellfestmény';

  @override
  String get stylePonyOil => 'Olajfestmény';

  @override
  String get stylePonyOilDesc => 'Vastag ecsetvonások vásznon';

  @override
  String get styleIllustriousOil => 'Olaj – impasztó';

  @override
  String get styleIllustriousOilDesc => 'Vastag impasztó festék, chiaroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japán animerajz';

  @override
  String get styleFlat => 'Lapos vektor';

  @override
  String get styleFlatDesc => 'Lapos színek és tiszta formák';

  @override
  String get styleUkiyoe => 'Ukijo-e';

  @override
  String get styleUkiyoeDesc => 'Japán fametszet';

  @override
  String get styleMucha => 'Szecesszió (Mucha)';

  @override
  String get styleMuchaDesc => 'Díszes szecesszió arany kiemelésekkel';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Posztimpresszionista örvénylő vonások';

  @override
  String get langAr => 'Arab';

  @override
  String get langCs => 'Cseh';

  @override
  String get langDe => 'Német';

  @override
  String get langEl => 'Görög';

  @override
  String get langEn => 'Angol';

  @override
  String get langEs419 => 'Spanyol';

  @override
  String get langFr => 'Francia';

  @override
  String get langHe => 'Héber';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonéz';

  @override
  String get langJa => 'Japán';

  @override
  String get langKo => 'Koreai';

  @override
  String get langPtBR => 'Portugál';

  @override
  String get langRu => 'Orosz';

  @override
  String get langTr => 'Török';

  @override
  String get langVi => 'Vietnámi';

  @override
  String get langZhCN => 'Kínai';
}
