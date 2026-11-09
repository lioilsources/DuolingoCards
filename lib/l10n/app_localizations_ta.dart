// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'டெக் ஸ்டோர்';

  @override
  String get homeEmptyTitle => 'இன்னும் டெக்குகள் இல்லை';

  @override
  String get homeReorderHint =>
      'வரிசையை மாற்ற ஒரு டெக்கை அழுத்திப் பிடித்து இழுக்கவும்';

  @override
  String get homeBrowseStore => 'டெக் ஸ்டோரைப் பார்க்கவும்';

  @override
  String get homeDownloadingDecks => 'உங்கள் டெக்குகள் தயாராகின்றன…';

  @override
  String get badgeFree => 'இலவசம்';

  @override
  String get badgeUnlocked => 'திறக்கப்பட்டது';

  @override
  String get badgePurchased => 'வாங்கப்பட்டது';

  @override
  String get badgePaidDeck => 'கட்டண டெக்';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count அட்டைகள்',
      one: '1 அட்டை',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards அட்டைகள்',
      one: '1 அட்டை',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs மொழிகள்',
      one: '1 மொழி',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count தெரிந்தவை';
  }

  @override
  String legendLearning(int count) {
    return '$count கற்கிறேன்';
  }

  @override
  String legendUnknown(int count) {
    return '$count தெரியாதவை';
  }

  @override
  String get storeTitle => 'டெக் ஸ்டோர்';

  @override
  String get storeRestorePurchases => 'வாங்கியவற்றை மீட்டமை';

  @override
  String get storeSearchHint => 'டெக்குகளைத் தேடுக…';

  @override
  String storeLoadError(String error) {
    return 'டெக்குகளை ஏற்ற முடியவில்லை: $error';
  }

  @override
  String get storeNoDecks => 'டெக்குகள் எதுவும் இல்லை.';

  @override
  String get storeNothingFound => 'எதுவும் கிடைக்கவில்லை.';

  @override
  String get retry => 'மீண்டும் முயல்க';

  @override
  String get buy => 'வாங்கு';

  @override
  String buyFor(String price) {
    return '$priceக்கு வாங்கு';
  }

  @override
  String get add => 'சேர்';

  @override
  String get addFree => 'இலவசமாகச் சேர்';

  @override
  String get back => 'பின்செல்';

  @override
  String get previous => 'முந்தையது';

  @override
  String get next => 'அடுத்தது';

  @override
  String get study => 'படி';

  @override
  String get download => 'பதிவிறக்கு';

  @override
  String get confirmLanguagesLabel => 'மொழிகள்';

  @override
  String get styleSectionTitle => 'படப் பாணி';

  @override
  String get confirmBuyNote =>
      'வாங்கினால் முழு டெக்கும் திறக்கும் — எல்லா மொழிகளும் எல்லாப் பாணிகளும். இந்தச் சேர்க்கை உங்கள் முகப்புத் திரையில் சேர்க்கப்படும்.';

  @override
  String get confirmAddNote =>
      'இந்தச் சேர்க்கை உங்கள் முகப்புத் திரையில் சேர்க்கப்படும். எப்போது வேண்டுமானாலும் வேறு மொழி அல்லது பாணியைச் சேர்க்கலாம்.';

  @override
  String get purchaseFailedToStart => 'வாங்குதலைத் தொடங்க முடியவில்லை.';

  @override
  String get addedToHome => 'முகப்புத் திரையில் சேர்க்கப்பட்டது.';

  @override
  String get downloadFailed => 'பதிவிறக்கம் தோல்வியடைந்தது. மீண்டும் முயலவும்.';

  @override
  String get deckNotPurchased => 'இந்த டெக் வாங்கப்படவில்லை.';

  @override
  String downloading(int percent) {
    return 'பதிவிறக்குகிறது… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count செயலில்',
      one: '1 செயலில்',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'தெரியும்';

  @override
  String get pickerLearning => 'கற்கிறேன்';

  @override
  String get reportIssue => 'சிக்கலைப் புகாரளி';

  @override
  String get issueTranslation => 'மொழிபெயர்ப்பு';

  @override
  String get issueImage => 'படம்';

  @override
  String get issuePronunciation => 'உச்சரிப்பு';

  @override
  String get issueMeaning => 'பொருள் / உண்மைகள்';

  @override
  String get issueOther => 'மற்றவை';

  @override
  String get feedbackCommentHint => 'என்ன தவறு? (விருப்பத்தேர்வு)';

  @override
  String get feedbackSend => 'மின்னஞ்சலில் அனுப்பு';

  @override
  String feedbackNoMailApp(String email) {
    return 'மின்னஞ்சல் ஆப் எதுவும் இல்லை. புகார் கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது — அதை $email க்கு அனுப்பவும்.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] அட்டைச் சிக்கல் $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'டெக்: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'அட்டை: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'மொழிகள்: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'காட்டப்பட்டது: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'பாணி: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'சிக்கல் வகை: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'பெறுநர்: $email';
  }

  @override
  String get pronounce => 'உச்சரி';

  @override
  String get installVoice => 'குரலை நிறுவு';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\" க்கு குரல் எதுவும் நிறுவப்படவில்லை. அமைப்புகள் → அணுகல்தன்மை → பேசப்படும் உள்ளடக்கம் → குரல்கள் என்பதில் ஒன்றைச் சேர்த்து மீண்டும் முயலவும்.';
  }

  @override
  String get playPronunciation => 'உச்சரிப்பை இயக்கு';

  @override
  String get swipeNext => 'அடுத்தது';

  @override
  String get swipeBack => 'பின்';

  @override
  String get showTranslation => 'மொழிபெயர்ப்பைக் காட்டு';

  @override
  String get showOriginal => 'மூலத்தைக் காட்டு';

  @override
  String get noCards => 'அட்டைகள் இல்லை';

  @override
  String get deckHasNoCards => 'இந்த டெக்கில் அட்டைகள் இல்லை.';

  @override
  String get flashcards => 'ஃபிளாஷ் அட்டைகள்';

  @override
  String get stylePhoto => 'புகைப்படம்';

  @override
  String get stylePhotoDesc => 'தெளிவான புகைப்படம், உண்மைக்கு மிக அருகில்';

  @override
  String get styleInk => 'தூரிகையும் மையும்';

  @override
  String get styleInkDesc =>
      'தூரிகைக் கோடுகள், வெற்றுத் தாள், ஒரு வண்ணத் தொடுதல்';

  @override
  String get stylePastel => 'பாஸ்டல்';

  @override
  String get stylePastelDesc => 'வண்ணத் தாளில் உலர் பாஸ்டல்';

  @override
  String get styleWatercolor => 'நீர்வண்ணம்';

  @override
  String get styleWatercolorDesc => 'பரவும் நீர்வண்ணம், தாள் தெரியும்';

  @override
  String get styleFlag => 'கொடிகள்';

  @override
  String get styleFlagDesc => 'உண்மையான தேசியக் கொடிகள்';

  @override
  String get stylePonyCartoon => 'கார்ட்டூன்';

  @override
  String get stylePonyCartoonDesc => 'வண்ணமயமான கார்ட்டூன் ஓவியம்';

  @override
  String get styleStorybook => 'கதைப் புத்தகம்';

  @override
  String get styleStorybookDesc => 'மென்மையான புத்தக ஓவியம்';

  @override
  String get stylePonyWatercolor => 'நீர்வண்ணம் – மென்மை';

  @override
  String get stylePonyWatercolorDesc => 'மென்மையான நீர்வண்ண ஓவியம்';

  @override
  String get stylePonyOil => 'எண்ணெய் ஓவியம்';

  @override
  String get stylePonyOilDesc => 'கேன்வாஸில் தடித்த தூரிகைக் கோடுகள்';

  @override
  String get styleIllustriousOil => 'எண்ணெய் – இம்பாஸ்டோ';

  @override
  String get styleIllustriousOilDesc =>
      'அடர்த்தியான இம்பாஸ்டோ வண்ணம், ஒளி-நிழல்';

  @override
  String get styleAnime => 'அனிமே';

  @override
  String get styleAnimeDesc => 'ஜப்பானிய அனிமே ஓவியம்';

  @override
  String get styleFlat => 'தட்டையான வெக்டர்';

  @override
  String get styleFlatDesc => 'தட்டையான வண்ணங்கள், சுத்தமான வடிவங்கள்';

  @override
  String get styleUkiyoe => 'உகியோ-எ';

  @override
  String get styleUkiyoeDesc => 'ஜப்பானிய மரச்சிற்ப அச்சு';

  @override
  String get styleMucha => 'ஆர்ட் நூவோ (முகா)';

  @override
  String get styleMuchaDesc => 'தங்கத் தொடுதல்களுடன் அலங்கார ஆர்ட் நூவோ';

  @override
  String get styleVanGogh => 'வான் கோ';

  @override
  String get styleVanGoghDesc => 'பின்-இம்ப்ரஷனிச சுழல் கோடுகள்';

  @override
  String get langAr => 'அரபு';

  @override
  String get langCs => 'செக்';

  @override
  String get langDe => 'ஜெர்மன்';

  @override
  String get langEl => 'கிரேக்கம்';

  @override
  String get langEn => 'ஆங்கிலம்';

  @override
  String get langEs419 => 'ஸ்பானிஷ்';

  @override
  String get langFr => 'பிரெஞ்சு';

  @override
  String get langHe => 'ஹீப்ரு';

  @override
  String get langHi => 'இந்தி';

  @override
  String get langId => 'இந்தோனேசியம்';

  @override
  String get langJa => 'ஜப்பானியம்';

  @override
  String get langKo => 'கொரியன்';

  @override
  String get langPtBR => 'போர்த்துகீசியம்';

  @override
  String get langRu => 'ரஷ்யன்';

  @override
  String get langTr => 'துருக்கியம்';

  @override
  String get langVi => 'வியட்நாமியம்';

  @override
  String get langZhCN => 'சீனம்';
}
