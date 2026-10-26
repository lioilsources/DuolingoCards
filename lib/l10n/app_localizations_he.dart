// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'חנות החפיסות';

  @override
  String get homeEmptyTitle => 'עדיין אין חפיסות';

  @override
  String get homeReorderHint => 'לחיצה ארוכה על חפיסה וגרירה משנות את הסדר';

  @override
  String get homeBrowseStore => 'לחנות החפיסות';

  @override
  String get homeDownloadingDecks => 'מכינים את החפיסות שלך…';

  @override
  String get badgeFree => 'חינם';

  @override
  String get badgeUnlocked => 'פתוח';

  @override
  String get badgePurchased => 'נרכש';

  @override
  String get badgePaidDeck => 'חפיסה בתשלום';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count כרטיסים',
      two: 'שני כרטיסים',
      one: 'כרטיס אחד',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards כרטיסים',
      two: 'שני כרטיסים',
      one: 'כרטיס אחד',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs שפות',
      two: 'שתי שפות',
      one: 'שפה אחת',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return 'יודע/ת: $count';
  }

  @override
  String legendLearning(int count) {
    return 'לומד/ת: $count';
  }

  @override
  String legendUnknown(int count) {
    return 'לא יודע/ת: $count';
  }

  @override
  String get storeTitle => 'חנות החפיסות';

  @override
  String get storeRestorePurchases => 'שחזור רכישות';

  @override
  String get storeSearchHint => 'חיפוש חפיסות…';

  @override
  String storeLoadError(String error) {
    return 'לא ניתן לטעון את החפיסות: $error';
  }

  @override
  String get storeNoDecks => 'אין חפיסות זמינות.';

  @override
  String get storeNothingFound => 'לא נמצא דבר.';

  @override
  String get retry => 'לנסות שוב';

  @override
  String get buy => 'קנייה';

  @override
  String buyFor(String price) {
    return 'קנייה ב-$price';
  }

  @override
  String get add => 'הוספה';

  @override
  String get addFree => 'הוספה בחינם';

  @override
  String get back => 'חזרה';

  @override
  String get previous => 'הקודם';

  @override
  String get next => 'הבא';

  @override
  String get study => 'ללמוד';

  @override
  String get download => 'הורדה';

  @override
  String get confirmLanguagesLabel => 'שפות';

  @override
  String get styleSectionTitle => 'סגנון תמונות';

  @override
  String get confirmBuyNote =>
      'הקנייה פותחת את כל החפיסה — כל השפות וכל הסגנונות. השילוב הזה יתווסף למסך הבית שלך.';

  @override
  String get confirmAddNote =>
      'השילוב הזה יתווסף למסך הבית שלך. אפשר להוסיף שפה או סגנון נוספים בכל עת.';

  @override
  String get purchaseFailedToStart => 'לא ניתן להתחיל את הרכישה.';

  @override
  String get addedToHome => 'נוסף למסך הבית שלך.';

  @override
  String get downloadFailed => 'ההורדה נכשלה. כדאי לנסות שוב.';

  @override
  String get deckNotPurchased => 'החפיסה הזו עדיין לא נרכשה.';

  @override
  String downloading(int percent) {
    return 'מוריד… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count פעילים',
      two: 'שניים פעילים',
      one: 'אחד פעיל',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'יודע/ת';

  @override
  String get pickerLearning => 'לומד/ת';

  @override
  String get reportIssue => 'דיווח על בעיה';

  @override
  String get issueTranslation => 'תרגום';

  @override
  String get issueImage => 'תמונה';

  @override
  String get issuePronunciation => 'הגייה';

  @override
  String get issueMeaning => 'משמעות / עובדות';

  @override
  String get issueOther => 'אחר';

  @override
  String get feedbackCommentHint => 'מה לא בסדר? (לא חובה)';

  @override
  String get feedbackSend => 'שליחה בדוא״ל';

  @override
  String feedbackNoMailApp(String email) {
    return 'אין אפליקציית דוא״ל זמינה. הדיווח הועתק ללוח — נא לשלוח אותו אל $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] בעיה בכרטיס $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'חפיסה: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'כרטיס: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'שפות: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'מוצג: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'סגנון: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'סוג הבעיה: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'אל: $email';
  }

  @override
  String get pronounce => 'הגייה';

  @override
  String get installVoice => 'התקנת קול';

  @override
  String noVoiceInstalled(String lang) {
    return 'לא מותקן קול עבור \"$lang\". אפשר להוסיף קול ב״הגדרות → נגישות → תוכן מוקרא → קולות״ ואז לנסות שוב.';
  }

  @override
  String get playPronunciation => 'השמעת ההגייה';

  @override
  String get swipeNext => 'הבא';

  @override
  String get swipeBack => 'חזרה';

  @override
  String get showTranslation => 'הצגת התרגום';

  @override
  String get showOriginal => 'הצגת המקור';

  @override
  String get noCards => 'אין כרטיסים';

  @override
  String get deckHasNoCards => 'אין כרטיסים בחפיסה הזו.';

  @override
  String get flashcards => 'כרטיסיות';

  @override
  String get stylePhoto => 'צילום';

  @override
  String get stylePhotoDesc => 'צילום חד, הכי קרוב למציאות';

  @override
  String get styleInk => 'מכחול ודיו';

  @override
  String get styleInkDesc => 'משיכות מכחול, נייר חשוף ונגיעת צבע אחת';

  @override
  String get stylePastel => 'פסטל';

  @override
  String get stylePastelDesc => 'פסטל יבש על נייר צבעוני';

  @override
  String get styleWatercolor => 'צבעי מים';

  @override
  String get styleWatercolorDesc => 'כתמי צבע זורמים והנייר מבצבץ מבעדם';

  @override
  String get styleFlag => 'דגלים';

  @override
  String get styleFlagDesc => 'דגלי המדינות האמיתיים';

  @override
  String get stylePonyCartoon => 'מצויר';

  @override
  String get stylePonyCartoonDesc => 'איור מצויר וצבעוני';

  @override
  String get styleStorybook => 'ספר סיפורים';

  @override
  String get styleStorybookDesc => 'איור רך כמו בספר ילדים';

  @override
  String get stylePonyWatercolor => 'צבעי מים – רך';

  @override
  String get stylePonyWatercolorDesc => 'ציור רך בצבעי מים';

  @override
  String get stylePonyOil => 'ציור שמן';

  @override
  String get stylePonyOilDesc => 'משיכות מכחול עבות על קנבס';

  @override
  String get styleIllustriousOil => 'שמן – אימפסטו';

  @override
  String get styleIllustriousOilDesc => 'צבע עבה וניגודי אור וצל';

  @override
  String get styleAnime => 'אנימה';

  @override
  String get styleAnimeDesc => 'ציור אנימה יפני';

  @override
  String get styleFlat => 'וקטור שטוח';

  @override
  String get styleFlatDesc => 'צבעים שטוחים וצורות נקיות';

  @override
  String get styleUkiyoe => 'אוקיו-אה';

  @override
  String get styleUkiyoeDesc => 'הדפס עץ יפני';

  @override
  String get styleMucha => 'אר נובו (מוכה)';

  @override
  String get styleMuchaDesc => 'אר נובו מעוטר עם נגיעות זהב';

  @override
  String get styleVanGogh => 'ואן גוך';

  @override
  String get styleVanGoghDesc => 'משיכות מסתלסלות בסגנון פוסט־אימפרסיוניסטי';

  @override
  String get langAr => 'ערבית';

  @override
  String get langCs => 'צ׳כית';

  @override
  String get langDe => 'גרמנית';

  @override
  String get langEl => 'יוונית';

  @override
  String get langEn => 'אנגלית';

  @override
  String get langEs419 => 'ספרדית';

  @override
  String get langFr => 'צרפתית';

  @override
  String get langHe => 'עברית';

  @override
  String get langHi => 'הינדי';

  @override
  String get langId => 'אינדונזית';

  @override
  String get langJa => 'יפנית';

  @override
  String get langKo => 'קוריאנית';

  @override
  String get langPtBR => 'פורטוגזית';

  @override
  String get langRu => 'רוסית';

  @override
  String get langTr => 'טורקית';

  @override
  String get langVi => 'וייטנאמית';

  @override
  String get langZhCN => 'סינית';
}
