// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'متجر المجموعات';

  @override
  String get homeEmptyTitle => 'لا توجد مجموعات بعد';

  @override
  String get homeReorderHint => 'اضغط مطولًا على مجموعة واسحبها لتغيير ترتيبها';

  @override
  String get homeBrowseStore => 'تصفّح متجر المجموعات';

  @override
  String get homeDownloadingDecks => 'نجهّز مجموعاتك…';

  @override
  String get badgeFree => 'مجاني';

  @override
  String get badgeUnlocked => 'مفتوح';

  @override
  String get badgePurchased => 'تم الشراء';

  @override
  String get badgePaidDeck => 'مجموعة مدفوعة';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بطاقة',
      many: '$count بطاقة',
      few: '$count بطاقات',
      two: 'بطاقتان',
      one: 'بطاقة واحدة',
      zero: 'لا بطاقات',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards بطاقة',
      many: '$cards بطاقة',
      few: '$cards بطاقات',
      two: 'بطاقتان',
      one: 'بطاقة واحدة',
      zero: 'لا بطاقات',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs لغة',
      many: '$langs لغة',
      few: '$langs لغات',
      two: 'لغتان',
      one: 'لغة واحدة',
      zero: 'لا لغات',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return 'أعرفها: $count';
  }

  @override
  String legendLearning(int count) {
    return 'أتعلّمها: $count';
  }

  @override
  String legendUnknown(int count) {
    return 'لا أعرفها: $count';
  }

  @override
  String get storeTitle => 'متجر المجموعات';

  @override
  String get storeRestorePurchases => 'استعادة المشتريات';

  @override
  String get storeSearchHint => 'ابحث عن مجموعات…';

  @override
  String storeLoadError(String error) {
    return 'تعذّر تحميل المجموعات: $error';
  }

  @override
  String get storeNoDecks => 'لا توجد مجموعات متاحة.';

  @override
  String get storeNothingFound => 'لم يتم العثور على شيء.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get buy => 'شراء';

  @override
  String buyFor(String price) {
    return 'شراء مقابل $price';
  }

  @override
  String get add => 'إضافة';

  @override
  String get addFree => 'إضافة مجانًا';

  @override
  String get back => 'رجوع';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get study => 'تعلّم';

  @override
  String get download => 'تنزيل';

  @override
  String get confirmLanguagesLabel => 'اللغات';

  @override
  String get styleSectionTitle => 'نمط الصور';

  @override
  String get confirmBuyNote =>
      'الشراء يفتح المجموعة كاملة — كل اللغات وكل الأنماط. ستُضاف هذه التركيبة إلى شاشتك الرئيسية.';

  @override
  String get confirmAddNote =>
      'ستُضاف هذه التركيبة إلى شاشتك الرئيسية. يمكنك إضافة لغة أو نمط آخر في أي وقت.';

  @override
  String get purchaseFailedToStart => 'تعذّر بدء عملية الشراء.';

  @override
  String get addedToHome => 'أُضيفت إلى شاشتك الرئيسية.';

  @override
  String get downloadFailed => 'فشل التنزيل. يُرجى المحاولة مرة أخرى.';

  @override
  String get deckNotPurchased => 'لم يتم شراء هذه المجموعة.';

  @override
  String downloading(int percent) {
    return 'جارٍ التنزيل… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مفعّلة',
      many: '$count مفعّلة',
      few: '$count مفعّلة',
      two: 'اثنتان مفعّلتان',
      one: 'واحدة مفعّلة',
      zero: 'لا شيء مفعّل',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'أعرفها';

  @override
  String get pickerLearning => 'أتعلّمها';

  @override
  String get reportIssue => 'الإبلاغ عن مشكلة';

  @override
  String get issueTranslation => 'الترجمة';

  @override
  String get issueImage => 'الصورة';

  @override
  String get issuePronunciation => 'النطق';

  @override
  String get issueMeaning => 'المعنى / المعلومات';

  @override
  String get issueOther => 'أخرى';

  @override
  String get feedbackCommentHint => 'ما الخطأ؟ (اختياري)';

  @override
  String get feedbackSend => 'إرسال بالبريد الإلكتروني';

  @override
  String feedbackNoMailApp(String email) {
    return 'لا يوجد تطبيق بريد إلكتروني. تم نسخ البلاغ إلى الحافظة — يُرجى إرساله إلى $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] مشكلة في بطاقة $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'المجموعة: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'البطاقة: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'اللغات: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'المعروض: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'النمط: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'نوع المشكلة: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'إلى: $email';
  }

  @override
  String get pronounce => 'انطق';

  @override
  String get installVoice => 'تثبيت صوت';

  @override
  String noVoiceInstalled(String lang) {
    return 'لا يوجد صوت مثبّت للغة \"$lang\". أضِف صوتًا من الإعدادات → تسهيلات الاستخدام → المحتوى المنطوق → الأصوات، ثم حاول مرة أخرى.';
  }

  @override
  String get playPronunciation => 'تشغيل النطق';

  @override
  String get swipeNext => 'التالي';

  @override
  String get swipeBack => 'رجوع';

  @override
  String get showTranslation => 'إظهار الترجمة';

  @override
  String get showOriginal => 'إظهار الأصل';

  @override
  String get noCards => 'لا توجد بطاقات';

  @override
  String get deckHasNoCards => 'لا تحتوي هذه المجموعة على بطاقات.';

  @override
  String get flashcards => 'بطاقات تعليمية';

  @override
  String get stylePhoto => 'صورة فوتوغرافية';

  @override
  String get stylePhotoDesc => 'صورة واضحة، الأقرب إلى الواقع';

  @override
  String get styleInk => 'فرشاة وحبر';

  @override
  String get styleInkDesc => 'ضربات فرشاة على ورق أبيض مع لمسة لون واحدة';

  @override
  String get stylePastel => 'باستيل';

  @override
  String get stylePastelDesc => 'باستيل جاف على ورق ملوّن';

  @override
  String get styleWatercolor => 'ألوان مائية';

  @override
  String get styleWatercolorDesc => 'ألوان مائية منسابة يظهر الورق من خلالها';

  @override
  String get styleFlag => 'أعلام';

  @override
  String get styleFlagDesc => 'أعلام الدول الحقيقية';

  @override
  String get stylePonyCartoon => 'كرتون';

  @override
  String get stylePonyCartoonDesc => 'رسم كرتوني ملوّن';

  @override
  String get styleStorybook => 'كتاب قصص';

  @override
  String get styleStorybookDesc => 'رسم ناعم كما في كتب الأطفال';

  @override
  String get stylePonyWatercolor => 'ألوان مائية – ناعمة';

  @override
  String get stylePonyWatercolorDesc => 'لوحة ناعمة بالألوان المائية';

  @override
  String get stylePonyOil => 'لوحة زيتية';

  @override
  String get stylePonyOilDesc => 'ضربات فرشاة كثيفة على القماش';

  @override
  String get styleIllustriousOil => 'زيت – طبقات كثيفة';

  @override
  String get styleIllustriousOilDesc => 'طلاء كثيف وتباين قوي بين الضوء والظل';

  @override
  String get styleAnime => 'أنمي';

  @override
  String get styleAnimeDesc => 'رسم أنمي ياباني';

  @override
  String get styleFlat => 'رسم مسطّح';

  @override
  String get styleFlatDesc => 'ألوان مسطّحة وأشكال بسيطة';

  @override
  String get styleUkiyoe => 'أوكيو-إه';

  @override
  String get styleUkiyoeDesc => 'طباعة يابانية بالقوالب الخشبية';

  @override
  String get styleMucha => 'الفن الحديث (موخا)';

  @override
  String get styleMuchaDesc => 'فن زخرفي حديث بلمسات ذهبية';

  @override
  String get styleVanGogh => 'فان غوخ';

  @override
  String get styleVanGoghDesc => 'ضربات دوّامية على طريقة ما بعد الانطباعية';

  @override
  String get langAr => 'العربية';

  @override
  String get langCs => 'التشيكية';

  @override
  String get langDe => 'الألمانية';

  @override
  String get langEl => 'اليونانية';

  @override
  String get langEn => 'الإنجليزية';

  @override
  String get langEs419 => 'الإسبانية';

  @override
  String get langFr => 'الفرنسية';

  @override
  String get langHe => 'العبرية';

  @override
  String get langHi => 'الهندية';

  @override
  String get langId => 'الإندونيسية';

  @override
  String get langJa => 'اليابانية';

  @override
  String get langKo => 'الكورية';

  @override
  String get langPtBR => 'البرتغالية';

  @override
  String get langRu => 'الروسية';

  @override
  String get langTr => 'التركية';

  @override
  String get langVi => 'الفيتنامية';

  @override
  String get langZhCN => 'الصينية';
}
