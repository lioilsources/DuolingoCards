// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'ডেক স্টোর';

  @override
  String get homeEmptyTitle => 'এখনও কোনো ডেক নেই';

  @override
  String get homeReorderHint => 'ক্রম বদলাতে কোনো ডেক চেপে ধরে টেনে আনুন';

  @override
  String get homeBrowseStore => 'ডেক স্টোর দেখুন';

  @override
  String get homeDownloadingDecks => 'আপনার ডেকগুলো প্রস্তুত করা হচ্ছে…';

  @override
  String get badgeFree => 'বিনামূল্যে';

  @override
  String get badgeUnlocked => 'আনলক করা';

  @override
  String get badgePurchased => 'কেনা হয়েছে';

  @override
  String get badgePaidDeck => 'পেইড ডেক';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি কার্ড',
      one: '$countটি কার্ড',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cardsটি কার্ড',
      one: '$cardsটি কার্ড',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langsটি ভাষা',
      one: '$langsটি ভাষা',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$countটি জানা';
  }

  @override
  String legendLearning(int count) {
    return '$countটি শেখা চলছে';
  }

  @override
  String legendUnknown(int count) {
    return '$countটি অজানা';
  }

  @override
  String get storeTitle => 'ডেক স্টোর';

  @override
  String get storeRestorePurchases => 'কেনাকাটা পুনরুদ্ধার করুন';

  @override
  String get storeSearchHint => 'ডেক খুঁজুন…';

  @override
  String storeLoadError(String error) {
    return 'ডেক লোড করা যায়নি: $error';
  }

  @override
  String get storeNoDecks => 'কোনো ডেক উপলব্ধ নেই।';

  @override
  String get storeNothingFound => 'কিছু পাওয়া যায়নি।';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get buy => 'কিনুন';

  @override
  String buyFor(String price) {
    return '$price-এ কিনুন';
  }

  @override
  String get add => 'যোগ করুন';

  @override
  String get addFree => 'বিনামূল্যে যোগ করুন';

  @override
  String get back => 'পিছনে';

  @override
  String get previous => 'আগের';

  @override
  String get next => 'পরের';

  @override
  String get study => 'পড়ুন';

  @override
  String get download => 'ডাউনলোড';

  @override
  String get confirmLanguagesLabel => 'ভাষা';

  @override
  String get styleSectionTitle => 'ছবির ধরন';

  @override
  String get confirmBuyNote =>
      'কিনলে পুরো ডেক আনলক হবে — সব ভাষা আর সব ধরন। এই সংমিশ্রণটি আপনার হোম স্ক্রিনে যোগ হবে।';

  @override
  String get confirmAddNote =>
      'এই সংমিশ্রণটি আপনার হোম স্ক্রিনে যোগ হবে। যেকোনো সময় অন্য ভাষা বা ধরন যোগ করতে পারবেন।';

  @override
  String get purchaseFailedToStart => 'কেনাকাটা শুরু করা যায়নি।';

  @override
  String get addedToHome => 'হোম স্ক্রিনে যোগ করা হয়েছে।';

  @override
  String get downloadFailed => 'ডাউনলোড ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get deckNotPurchased => 'এই ডেকটি কেনা হয়নি।';

  @override
  String downloading(int percent) {
    return 'ডাউনলোড হচ্ছে… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সক্রিয়',
      one: '$countটি সক্রিয়',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'জানি';

  @override
  String get pickerLearning => 'শিখছি';

  @override
  String get reportIssue => 'সমস্যা জানান';

  @override
  String get issueTranslation => 'অনুবাদ';

  @override
  String get issueImage => 'ছবি';

  @override
  String get issuePronunciation => 'উচ্চারণ';

  @override
  String get issueMeaning => 'অর্থ / তথ্য';

  @override
  String get issueOther => 'অন্যান্য';

  @override
  String get feedbackCommentHint => 'কী ভুল আছে? (ঐচ্ছিক)';

  @override
  String get feedbackSend => 'ই-মেইলে পাঠান';

  @override
  String feedbackNoMailApp(String email) {
    return 'কোনো ই-মেইল অ্যাপ নেই। রিপোর্টটি ক্লিপবোর্ডে কপি করা হয়েছে — অনুগ্রহ করে $email-এ পাঠান।';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] কার্ডে সমস্যা $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'ডেক: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'কার্ড: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'ভাষা: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'দেখানো হয়েছে: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'ধরন: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'সমস্যার ধরন: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'প্রাপক: $email';
  }

  @override
  String get pronounce => 'উচ্চারণ করুন';

  @override
  String get installVoice => 'ভয়েস ইনস্টল করুন';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\"-এর জন্য কোনো ভয়েস ইনস্টল করা নেই। সেটিংস → অ্যাক্সেসিবিলিটি → স্পোকেন কনটেন্ট → ভয়েস-এ গিয়ে একটি যোগ করুন, তারপর আবার চেষ্টা করুন।';
  }

  @override
  String get playPronunciation => 'উচ্চারণ শুনুন';

  @override
  String get swipeNext => 'পরের';

  @override
  String get swipeBack => 'পিছনে';

  @override
  String get showTranslation => 'অনুবাদ দেখান';

  @override
  String get showOriginal => 'মূল দেখান';

  @override
  String get noCards => 'কোনো কার্ড নেই';

  @override
  String get deckHasNoCards => 'এই ডেকে কোনো কার্ড নেই।';

  @override
  String get flashcards => 'ফ্ল্যাশকার্ড';

  @override
  String get stylePhoto => 'ছবি';

  @override
  String get stylePhotoDesc => 'স্পষ্ট আলোকচিত্র, বাস্তবের সবচেয়ে কাছে';

  @override
  String get styleInk => 'তুলি ও কালি';

  @override
  String get styleInkDesc => 'তুলির টান, ফাঁকা কাগজ, একটি রঙের ছোঁয়া';

  @override
  String get stylePastel => 'প্যাস্টেল';

  @override
  String get stylePastelDesc => 'রঙিন কাগজে শুকনো প্যাস্টেল';

  @override
  String get styleWatercolor => 'জলরং';

  @override
  String get styleWatercolorDesc => 'ছড়িয়ে পড়া জলরং, কাগজ দেখা যায়';

  @override
  String get styleFlag => 'পতাকা';

  @override
  String get styleFlagDesc => 'আসল জাতীয় পতাকা';

  @override
  String get stylePonyCartoon => 'কার্টুন';

  @override
  String get stylePonyCartoonDesc => 'রঙিন কার্টুন চিত্র';

  @override
  String get styleStorybook => 'গল্পের বই';

  @override
  String get styleStorybookDesc => 'কোমল বইয়ের চিত্র';

  @override
  String get stylePonyWatercolor => 'জলরং – কোমল';

  @override
  String get stylePonyWatercolorDesc => 'কোমল জলরঙের ছবি';

  @override
  String get stylePonyOil => 'তৈলচিত্র';

  @override
  String get stylePonyOilDesc => 'ক্যানভাসে মোটা তুলির টান';

  @override
  String get styleIllustriousOil => 'তেলরং – ইমপাস্টো';

  @override
  String get styleIllustriousOilDesc => 'ঘন ইমপাস্টো রং, আলো-ছায়া';

  @override
  String get styleAnime => 'অ্যানিমে';

  @override
  String get styleAnimeDesc => 'জাপানি অ্যানিমে আঁকা';

  @override
  String get styleFlat => 'ফ্ল্যাট ভেক্টর';

  @override
  String get styleFlatDesc => 'সমতল রং আর পরিষ্কার আকার';

  @override
  String get styleUkiyoe => 'উকিয়ো-এ';

  @override
  String get styleUkiyoeDesc => 'জাপানি কাঠখোদাই ছাপ';

  @override
  String get styleMucha => 'আর্ট নুভো (মুখা)';

  @override
  String get styleMuchaDesc => 'সোনালি ছোঁয়ায় অলংকৃত আর্ট নুভো';

  @override
  String get styleVanGogh => 'ভ্যান গখ';

  @override
  String get styleVanGoghDesc => 'পোস্ট-ইম্প্রেশনিস্ট ঘূর্ণি টান';

  @override
  String get langAr => 'আরবি';

  @override
  String get langCs => 'চেক';

  @override
  String get langDe => 'জার্মান';

  @override
  String get langEl => 'গ্রিক';

  @override
  String get langEn => 'ইংরেজি';

  @override
  String get langEs419 => 'স্প্যানিশ';

  @override
  String get langFr => 'ফরাসি';

  @override
  String get langHe => 'হিব্রু';

  @override
  String get langHi => 'হিন্দি';

  @override
  String get langId => 'ইন্দোনেশীয়';

  @override
  String get langJa => 'জাপানি';

  @override
  String get langKo => 'কোরীয়';

  @override
  String get langPtBR => 'পর্তুগিজ';

  @override
  String get langRu => 'রুশ';

  @override
  String get langTr => 'তুর্কি';

  @override
  String get langVi => 'ভিয়েতনামি';

  @override
  String get langZhCN => 'চীনা';
}
