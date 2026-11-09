// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Magazin de pachete';

  @override
  String get homeEmptyTitle => 'Încă nu ai pachete';

  @override
  String get homeReorderHint =>
      'Ține apăsat pe un pachet și trage-l pentru a schimba ordinea';

  @override
  String get homeBrowseStore => 'Răsfoiește magazinul de pachete';

  @override
  String get homeDownloadingDecks => 'Îți pregătim pachetele…';

  @override
  String get badgeFree => 'Gratuit';

  @override
  String get badgeUnlocked => 'Deblocat';

  @override
  String get badgePurchased => 'Cumpărat';

  @override
  String get badgePaidDeck => 'Pachet cu plată';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de cartonașe',
      few: '$count cartonașe',
      one: '1 cartonaș',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards de cartonașe',
      few: '$cards cartonașe',
      one: '1 cartonaș',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs de limbi',
      few: '$langs limbi',
      one: '1 limbă',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return 'Știute: $count';
  }

  @override
  String legendLearning(int count) {
    return 'În învățare: $count';
  }

  @override
  String legendUnknown(int count) {
    return 'Neștiute: $count';
  }

  @override
  String get storeTitle => 'Magazin de pachete';

  @override
  String get storeRestorePurchases => 'Restabilește achizițiile';

  @override
  String get storeSearchHint => 'Caută pachete…';

  @override
  String storeLoadError(String error) {
    return 'Pachetele nu au putut fi încărcate: $error';
  }

  @override
  String get storeNoDecks => 'Nu există pachete disponibile.';

  @override
  String get storeNothingFound => 'Nu s-a găsit nimic.';

  @override
  String get retry => 'Reîncearcă';

  @override
  String get buy => 'Cumpără';

  @override
  String buyFor(String price) {
    return 'Cumpără cu $price';
  }

  @override
  String get add => 'Adaugă';

  @override
  String get addFree => 'Adaugă gratuit';

  @override
  String get back => 'Înapoi';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Următor';

  @override
  String get study => 'Învață';

  @override
  String get download => 'Descarcă';

  @override
  String get confirmLanguagesLabel => 'Limbi';

  @override
  String get styleSectionTitle => 'Stilul imaginilor';

  @override
  String get confirmBuyNote =>
      'Cumpărarea deblochează întregul pachet — toate limbile și toate stilurile. Această combinație va fi adăugată pe ecranul principal.';

  @override
  String get confirmAddNote =>
      'Această combinație va fi adăugată pe ecranul principal. Poți adăuga oricând o altă limbă sau un alt stil.';

  @override
  String get purchaseFailedToStart => 'Achiziția nu a putut fi pornită.';

  @override
  String get addedToHome => 'Adăugat pe ecranul principal.';

  @override
  String get downloadFailed => 'Descărcarea a eșuat. Încearcă din nou.';

  @override
  String get deckNotPurchased => 'Acest pachet nu a fost cumpărat.';

  @override
  String downloading(int percent) {
    return 'Se descarcă… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de active',
      few: '$count active',
      one: '1 activă',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Știu';

  @override
  String get pickerLearning => 'Învăț';

  @override
  String get reportIssue => 'Raportează o problemă';

  @override
  String get issueTranslation => 'Traducere';

  @override
  String get issueImage => 'Imagine';

  @override
  String get issuePronunciation => 'Pronunție';

  @override
  String get issueMeaning => 'Sens / fapte';

  @override
  String get issueOther => 'Altceva';

  @override
  String get feedbackCommentHint => 'Ce nu este în regulă? (opțional)';

  @override
  String get feedbackSend => 'Trimite pe e-mail';

  @override
  String feedbackNoMailApp(String email) {
    return 'Nu există nicio aplicație de e-mail. Raportul a fost copiat în clipboard — trimite-l la $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Problemă la cartonașul $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Pachet: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Cartonaș: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Limbi: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Afișat: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Stil: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Tipul problemei: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Către: $email';
  }

  @override
  String get pronounce => 'Pronunță';

  @override
  String get installVoice => 'Instalează vocea';

  @override
  String noVoiceInstalled(String lang) {
    return 'Nu este instalată nicio voce pentru „$lang”. Adaug-o în Configurări → Accesibilitate → Conținut vorbit → Voci, apoi încearcă din nou.';
  }

  @override
  String get playPronunciation => 'Redă pronunția';

  @override
  String get swipeNext => 'URMĂTOR';

  @override
  String get swipeBack => 'ÎNAPOI';

  @override
  String get showTranslation => 'Arată traducerea';

  @override
  String get showOriginal => 'Arată originalul';

  @override
  String get noCards => 'Niciun cartonaș';

  @override
  String get deckHasNoCards => 'Acest pachet nu are cartonașe.';

  @override
  String get flashcards => 'Cartonașe';

  @override
  String get stylePhoto => 'Fotografie';

  @override
  String get stylePhotoDesc => 'Fotografie clară, cât mai aproape de realitate';

  @override
  String get styleInk => 'Pensulă și tuș';

  @override
  String get styleInkDesc =>
      'Tușe de pensulă, hârtie goală, un singur accent de culoare';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Pastel uscat pe hârtie colorată';

  @override
  String get styleWatercolor => 'Acuarelă';

  @override
  String get styleWatercolorDesc => 'Pete difuze prin care se vede hârtia';

  @override
  String get styleFlag => 'Steaguri';

  @override
  String get styleFlagDesc => 'Steagurile naționale reale';

  @override
  String get stylePonyCartoon => 'Desen animat';

  @override
  String get stylePonyCartoonDesc => 'Ilustrație colorată de desen animat';

  @override
  String get styleStorybook => 'Carte de povești';

  @override
  String get styleStorybookDesc => 'Ilustrație delicată de carte';

  @override
  String get stylePonyWatercolor => 'Acuarelă – delicată';

  @override
  String get stylePonyWatercolorDesc => 'Pictură delicată în acuarelă';

  @override
  String get stylePonyOil => 'Pictură în ulei';

  @override
  String get stylePonyOilDesc => 'Tușe groase de pensulă pe pânză';

  @override
  String get styleIllustriousOil => 'Ulei – impasto';

  @override
  String get styleIllustriousOilDesc => 'Vopsea groasă impasto, clarobscur';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Desen anime japonez';

  @override
  String get styleFlat => 'Vector plat';

  @override
  String get styleFlatDesc => 'Culori plate și forme curate';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Gravură japoneză în lemn';

  @override
  String get styleMucha => 'Art Nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Art nouveau ornamental cu accente aurii';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Tușe postimpresioniste în vârtejuri';

  @override
  String get langAr => 'Arabă';

  @override
  String get langCs => 'Cehă';

  @override
  String get langDe => 'Germană';

  @override
  String get langEl => 'Greacă';

  @override
  String get langEn => 'Engleză';

  @override
  String get langEs419 => 'Spaniolă';

  @override
  String get langFr => 'Franceză';

  @override
  String get langHe => 'Ebraică';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indoneziană';

  @override
  String get langJa => 'Japoneză';

  @override
  String get langKo => 'Coreeană';

  @override
  String get langPtBR => 'Portugheză';

  @override
  String get langRu => 'Rusă';

  @override
  String get langTr => 'Turcă';

  @override
  String get langVi => 'Vietnameză';

  @override
  String get langZhCN => 'Chineză';
}
