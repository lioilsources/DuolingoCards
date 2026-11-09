// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'ڈیک اسٹور';

  @override
  String get homeEmptyTitle => 'ابھی کوئی ڈیک نہیں';

  @override
  String get homeReorderHint =>
      'ترتیب بدلنے کے لیے کسی ڈیک کو دبا کر رکھیں اور گھسیٹیں';

  @override
  String get homeBrowseStore => 'ڈیک اسٹور دیکھیں';

  @override
  String get homeDownloadingDecks => 'آپ کے ڈیک تیار کیے جا رہے ہیں…';

  @override
  String get badgeFree => 'مفت';

  @override
  String get badgeUnlocked => 'کھلا ہوا';

  @override
  String get badgePurchased => 'خریدا گیا';

  @override
  String get badgePaidDeck => 'ادائیگی والا ڈیک';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کارڈ',
      one: '1 کارڈ',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards کارڈ',
      one: '1 کارڈ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs زبانیں',
      one: '1 زبان',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count معلوم';
  }

  @override
  String legendLearning(int count) {
    return '$count زیرِ مشق';
  }

  @override
  String legendUnknown(int count) {
    return '$count نامعلوم';
  }

  @override
  String get storeTitle => 'ڈیک اسٹور';

  @override
  String get storeRestorePurchases => 'خریداریاں بحال کریں';

  @override
  String get storeSearchHint => 'ڈیک تلاش کریں…';

  @override
  String storeLoadError(String error) {
    return 'ڈیک لوڈ نہیں ہو سکے: $error';
  }

  @override
  String get storeNoDecks => 'کوئی ڈیک دستیاب نہیں۔';

  @override
  String get storeNothingFound => 'کچھ نہیں ملا۔';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get buy => 'خریدیں';

  @override
  String buyFor(String price) {
    return '$price میں خریدیں';
  }

  @override
  String get add => 'شامل کریں';

  @override
  String get addFree => 'مفت شامل کریں';

  @override
  String get back => 'واپس';

  @override
  String get previous => 'پچھلا';

  @override
  String get next => 'اگلا';

  @override
  String get study => 'پڑھیں';

  @override
  String get download => 'ڈاؤن لوڈ کریں';

  @override
  String get confirmLanguagesLabel => 'زبانیں';

  @override
  String get styleSectionTitle => 'تصویر کا انداز';

  @override
  String get confirmBuyNote =>
      'خریداری سے پورا ڈیک کھل جاتا ہے — ہر زبان اور ہر انداز۔ یہ مجموعہ آپ کی ہوم اسکرین پر شامل کر دیا جائے گا۔';

  @override
  String get confirmAddNote =>
      'یہ مجموعہ آپ کی ہوم اسکرین پر شامل کر دیا جائے گا۔ آپ کسی بھی وقت کوئی اور زبان یا انداز شامل کر سکتے ہیں۔';

  @override
  String get purchaseFailedToStart => 'خریداری شروع نہیں ہو سکی۔';

  @override
  String get addedToHome => 'ہوم اسکرین پر شامل کر دیا گیا۔';

  @override
  String get downloadFailed =>
      'ڈاؤن لوڈ ناکام ہو گیا۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get deckNotPurchased => 'یہ ڈیک خریدا نہیں گیا۔';

  @override
  String downloading(int percent) {
    return 'ڈاؤن لوڈ ہو رہا ہے… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فعال',
      one: '1 فعال',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'مجھے آتا ہے';

  @override
  String get pickerLearning => 'سیکھ رہا ہوں';

  @override
  String get reportIssue => 'مسئلہ رپورٹ کریں';

  @override
  String get issueTranslation => 'ترجمہ';

  @override
  String get issueImage => 'تصویر';

  @override
  String get issuePronunciation => 'تلفظ';

  @override
  String get issueMeaning => 'معنی / حقائق';

  @override
  String get issueOther => 'دیگر';

  @override
  String get feedbackCommentHint => 'کیا غلط ہے؟ (اختیاری)';

  @override
  String get feedbackSend => 'ای میل سے بھیجیں';

  @override
  String feedbackNoMailApp(String email) {
    return 'کوئی ای میل ایپ دستیاب نہیں۔ رپورٹ کلپ بورڈ پر کاپی کر دی گئی ہے — براہ کرم اسے $email پر بھیجیں۔';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] کارڈ میں مسئلہ $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'ڈیک: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'کارڈ: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'زبانیں: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'دکھایا گیا: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'انداز: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'مسئلے کی قسم: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'بنام: $email';
  }

  @override
  String get pronounce => 'تلفظ سنیں';

  @override
  String get installVoice => 'آواز انسٹال کریں';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\" کے لیے کوئی آواز انسٹال نہیں۔ سیٹنگز → ایکسیسبلٹی → اسپوکن کنٹینٹ → وائسز میں ایک شامل کریں، پھر دوبارہ کوشش کریں۔';
  }

  @override
  String get playPronunciation => 'تلفظ چلائیں';

  @override
  String get swipeNext => 'اگلا';

  @override
  String get swipeBack => 'واپس';

  @override
  String get showTranslation => 'ترجمہ دکھائیں';

  @override
  String get showOriginal => 'اصل دکھائیں';

  @override
  String get noCards => 'کوئی کارڈ نہیں';

  @override
  String get deckHasNoCards => 'اس ڈیک میں کوئی کارڈ نہیں۔';

  @override
  String get flashcards => 'فلیش کارڈز';

  @override
  String get stylePhoto => 'تصویر';

  @override
  String get stylePhotoDesc => 'واضح تصویر، حقیقت کے سب سے قریب';

  @override
  String get styleInk => 'برش اور سیاہی';

  @override
  String get styleInkDesc => 'برش کے اسٹروک، سادہ کاغذ، ایک رنگ کا لمس';

  @override
  String get stylePastel => 'پیسٹل';

  @override
  String get stylePastelDesc => 'رنگین کاغذ پر خشک پیسٹل';

  @override
  String get styleWatercolor => 'آبی رنگ';

  @override
  String get styleWatercolorDesc => 'پھیلتے آبی رنگ، جھلکتا کاغذ';

  @override
  String get styleFlag => 'جھنڈے';

  @override
  String get styleFlagDesc => 'اصل قومی جھنڈے';

  @override
  String get stylePonyCartoon => 'کارٹون';

  @override
  String get stylePonyCartoonDesc => 'رنگا رنگ کارٹون تصویر';

  @override
  String get styleStorybook => 'کہانی کی کتاب';

  @override
  String get styleStorybookDesc => 'نرم کتابی تصویر';

  @override
  String get stylePonyWatercolor => 'آبی رنگ – نرم';

  @override
  String get stylePonyWatercolorDesc => 'نرم آبی رنگ کی پینٹنگ';

  @override
  String get stylePonyOil => 'آئل پینٹنگ';

  @override
  String get stylePonyOilDesc => 'کینوس پر موٹے برش اسٹروک';

  @override
  String get styleIllustriousOil => 'آئل – امپاسٹو';

  @override
  String get styleIllustriousOilDesc =>
      'گاڑھا امپاسٹو رنگ، روشنی اور سائے کا کھیل';

  @override
  String get styleAnime => 'اینیمے';

  @override
  String get styleAnimeDesc => 'جاپانی اینیمے ڈرائنگ';

  @override
  String get styleFlat => 'فلیٹ ویکٹر';

  @override
  String get styleFlatDesc => 'سادہ رنگ اور صاف شکلیں';

  @override
  String get styleUkiyoe => 'اوکیو-ای';

  @override
  String get styleUkiyoeDesc => 'جاپانی لکڑی کا چھاپہ';

  @override
  String get styleMucha => 'آرٹ نووو (موخا)';

  @override
  String get styleMuchaDesc => 'سنہری لمس کے ساتھ آرائشی آرٹ نووو';

  @override
  String get styleVanGogh => 'وین گوخ';

  @override
  String get styleVanGoghDesc => 'پوسٹ امپریشنسٹ گھومتے اسٹروک';

  @override
  String get langAr => 'عربی';

  @override
  String get langCs => 'چیک';

  @override
  String get langDe => 'جرمن';

  @override
  String get langEl => 'یونانی';

  @override
  String get langEn => 'انگریزی';

  @override
  String get langEs419 => 'ہسپانوی';

  @override
  String get langFr => 'فرانسیسی';

  @override
  String get langHe => 'عبرانی';

  @override
  String get langHi => 'ہندی';

  @override
  String get langId => 'انڈونیشیائی';

  @override
  String get langJa => 'جاپانی';

  @override
  String get langKo => 'کوریائی';

  @override
  String get langPtBR => 'پرتگالی';

  @override
  String get langRu => 'روسی';

  @override
  String get langTr => 'ترکی';

  @override
  String get langVi => 'ویتنامی';

  @override
  String get langZhCN => 'چینی';
}
