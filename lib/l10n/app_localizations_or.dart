// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'ଡେକ୍ ଷ୍ଟୋର୍';

  @override
  String get homeEmptyTitle => 'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ଡେକ୍ ନାହିଁ';

  @override
  String get homeReorderHint => 'କ୍ରମ ବଦଳାଇବାକୁ ଡେକ୍‌କୁ ଦବାଇ ଧରି ଟାଣନ୍ତୁ';

  @override
  String get homeBrowseStore => 'ଡେକ୍ ଷ୍ଟୋର୍ ଦେଖନ୍ତୁ';

  @override
  String get homeDownloadingDecks => 'ଆପଣଙ୍କ ଡେକ୍ ପ୍ରସ୍ତୁତ ହେଉଛି…';

  @override
  String get badgeFree => 'ମାଗଣା';

  @override
  String get badgeUnlocked => 'ଅନଲକ୍ ହୋଇଛି';

  @override
  String get badgePurchased => 'କିଣାଯାଇଛି';

  @override
  String get badgePaidDeck => 'ଦେୟଯୁକ୍ତ ଡେକ୍';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countଟି କାର୍ଡ',
      one: '1ଟି କାର୍ଡ',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cardsଟି କାର୍ଡ',
      one: '1ଟି କାର୍ଡ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langsଟି ଭାଷା',
      one: '1ଟି ଭାଷା',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count ଜଣା';
  }

  @override
  String legendLearning(int count) {
    return '$count ଶିଖୁଛି';
  }

  @override
  String legendUnknown(int count) {
    return '$count ଅଜଣା';
  }

  @override
  String get storeTitle => 'ଡେକ୍ ଷ୍ଟୋର୍';

  @override
  String get storeRestorePurchases => 'କିଣାକିଣି ପୁନଃସ୍ଥାପନ କରନ୍ତୁ';

  @override
  String get storeSearchHint => 'ଡେକ୍ ଖୋଜନ୍ତୁ…';

  @override
  String storeLoadError(String error) {
    return 'ଡେକ୍ ଲୋଡ୍ ହୋଇପାରିଲା ନାହିଁ: $error';
  }

  @override
  String get storeNoDecks => 'କୌଣସି ଡେକ୍ ଉପଲବ୍ଧ ନାହିଁ।';

  @override
  String get storeNothingFound => 'କିଛି ମିଳିଲା ନାହିଁ।';

  @override
  String get retry => 'ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get buy => 'କିଣନ୍ତୁ';

  @override
  String buyFor(String price) {
    return '$priceରେ କିଣନ୍ତୁ';
  }

  @override
  String get add => 'ଯୋଡ଼ନ୍ତୁ';

  @override
  String get addFree => 'ମାଗଣାରେ ଯୋଡ଼ନ୍ତୁ';

  @override
  String get back => 'ପଛକୁ';

  @override
  String get previous => 'ପୂର୍ବବର୍ତ୍ତୀ';

  @override
  String get next => 'ପରବର୍ତ୍ତୀ';

  @override
  String get study => 'ପଢ଼ନ୍ତୁ';

  @override
  String get download => 'ଡାଉନଲୋଡ୍';

  @override
  String get confirmLanguagesLabel => 'ଭାଷା';

  @override
  String get styleSectionTitle => 'ଛବି ଶୈଳୀ';

  @override
  String get confirmBuyNote =>
      'କିଣିଲେ ସମଗ୍ର ଡେକ୍ ଅନଲକ୍ ହୁଏ — ସବୁ ଭାଷା ଓ ସବୁ ଶୈଳୀ। ଏହି ମିଶ୍ରଣ ଆପଣଙ୍କ ହୋମ୍ ସ୍କ୍ରିନ୍‌ରେ ଯୋଡ଼ାଯିବ।';

  @override
  String get confirmAddNote =>
      'ଏହି ମିଶ୍ରଣ ଆପଣଙ୍କ ହୋମ୍ ସ୍କ୍ରିନ୍‌ରେ ଯୋଡ଼ାଯିବ। ଆପଣ ଯେକୌଣସି ସମୟରେ ଅନ୍ୟ ଭାଷା ବା ଶୈଳୀ ଯୋଡ଼ିପାରିବେ।';

  @override
  String get purchaseFailedToStart => 'କିଣାକିଣି ଆରମ୍ଭ ହୋଇପାରିଲା ନାହିଁ।';

  @override
  String get addedToHome => 'ହୋମ୍ ସ୍କ୍ରିନ୍‌ରେ ଯୋଡ଼ାଗଲା।';

  @override
  String get downloadFailed => 'ଡାଉନଲୋଡ୍ ବିଫଳ ହେଲା। ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get deckNotPurchased => 'ଏହି ଡେକ୍ କିଣାଯାଇନାହିଁ।';

  @override
  String downloading(int percent) {
    return 'ଡାଉନଲୋଡ୍ ହେଉଛି… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countଟି ସକ୍ରିୟ',
      one: '1ଟି ସକ୍ରିୟ',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'ମୁଁ ଜାଣେ';

  @override
  String get pickerLearning => 'ଶିଖୁଛି';

  @override
  String get reportIssue => 'ସମସ୍ୟା ଜଣାନ୍ତୁ';

  @override
  String get issueTranslation => 'ଅନୁବାଦ';

  @override
  String get issueImage => 'ଛବି';

  @override
  String get issuePronunciation => 'ଉଚ୍ଚାରଣ';

  @override
  String get issueMeaning => 'ଅର୍ଥ / ତଥ୍ୟ';

  @override
  String get issueOther => 'ଅନ୍ୟାନ୍ୟ';

  @override
  String get feedbackCommentHint => 'କ\'ଣ ଭୁଲ୍ ଅଛି? (ଇଚ୍ଛାଧୀନ)';

  @override
  String get feedbackSend => 'ଇ-ମେଲ୍ ଦ୍ୱାରା ପଠାନ୍ତୁ';

  @override
  String feedbackNoMailApp(String email) {
    return 'କୌଣସି ଇ-ମେଲ୍ ଆପ୍ ଉପଲବ୍ଧ ନାହିଁ। ରିପୋର୍ଟ କ୍ଲିପବୋର୍ଡକୁ କପି ହୋଇଛି — ଦୟାକରି ଏହାକୁ $emailକୁ ପଠାନ୍ତୁ।';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] କାର୍ଡ ସମସ୍ୟା $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'ଡେକ୍: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'କାର୍ଡ: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'ଭାଷା: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'ଦେଖାଯାଇଥିବା: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'ଶୈଳୀ: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'ସମସ୍ୟାର ପ୍ରକାର: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'ପ୍ରାପକ: $email';
  }

  @override
  String get pronounce => 'ଉଚ୍ଚାରଣ କରନ୍ତୁ';

  @override
  String get installVoice => 'ସ୍ୱର ଇନଷ୍ଟଲ୍ କରନ୍ତୁ';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\" ପାଇଁ କୌଣସି ସ୍ୱର ଇନଷ୍ଟଲ୍ ହୋଇନାହିଁ। ସେଟିଂସ୍ → ଆକ୍ସେସିବିଲିଟି → ସ୍ପୋକେନ୍ କଣ୍ଟେଣ୍ଟ → ଭଏସେସ୍‌ରେ ଗୋଟିଏ ଯୋଡ଼ନ୍ତୁ, ତା\'ପରେ ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';
  }

  @override
  String get playPronunciation => 'ଉଚ୍ଚାରଣ ଶୁଣନ୍ତୁ';

  @override
  String get swipeNext => 'ପରବର୍ତ୍ତୀ';

  @override
  String get swipeBack => 'ପଛକୁ';

  @override
  String get showTranslation => 'ଅନୁବାଦ ଦେଖାନ୍ତୁ';

  @override
  String get showOriginal => 'ମୂଳ ଦେଖାନ୍ତୁ';

  @override
  String get noCards => 'କୌଣସି କାର୍ଡ ନାହିଁ';

  @override
  String get deckHasNoCards => 'ଏହି ଡେକ୍‌ରେ କୌଣସି କାର୍ଡ ନାହିଁ।';

  @override
  String get flashcards => 'ଫ୍ଲାସକାର୍ଡ';

  @override
  String get stylePhoto => 'ଫଟୋ';

  @override
  String get stylePhotoDesc => 'ସ୍ପଷ୍ଟ ଫଟୋ, ବାସ୍ତବର ସବୁଠୁ ନିକଟ';

  @override
  String get styleInk => 'ତୂଳି ଓ କାଳି';

  @override
  String get styleInkDesc => 'ତୂଳିର ଟାଣ, ଖାଲି କାଗଜ, ଗୋଟିଏ ରଙ୍ଗର ଛୁଆଁ';

  @override
  String get stylePastel => 'ପେଷ୍ଟେଲ୍';

  @override
  String get stylePastelDesc => 'ରଙ୍ଗୀନ କାଗଜରେ ଶୁଖିଲା ପେଷ୍ଟେଲ୍';

  @override
  String get styleWatercolor => 'ଜଳରଙ୍ଗ';

  @override
  String get styleWatercolorDesc => 'ବିଛୁଡ଼ୁଥିବା ଜଳରଙ୍ଗ, କାଗଜ ଦେଖାଯାଏ';

  @override
  String get styleFlag => 'ପତାକା';

  @override
  String get styleFlagDesc => 'ପ୍ରକୃତ ଜାତୀୟ ପତାକା';

  @override
  String get stylePonyCartoon => 'କାର୍ଟୁନ୍';

  @override
  String get stylePonyCartoonDesc => 'ରଙ୍ଗୀନ କାର୍ଟୁନ୍ ଚିତ୍ର';

  @override
  String get styleStorybook => 'ଗପ ବହି';

  @override
  String get styleStorybookDesc => 'କୋମଳ ବହି ଚିତ୍ର';

  @override
  String get stylePonyWatercolor => 'ଜଳରଙ୍ଗ – କୋମଳ';

  @override
  String get stylePonyWatercolorDesc => 'କୋମଳ ଜଳରଙ୍ଗ ଚିତ୍ର';

  @override
  String get stylePonyOil => 'ତୈଳଚିତ୍ର';

  @override
  String get stylePonyOilDesc => 'କ୍ୟାନଭାସ୍‌ରେ ମୋଟା ତୂଳି ଟାଣ';

  @override
  String get styleIllustriousOil => 'ତୈଳ – ଇମ୍ପାଷ୍ଟୋ';

  @override
  String get styleIllustriousOilDesc => 'ଘନ ଇମ୍ପାଷ୍ଟୋ ରଙ୍ଗ, ଆଲୋକ-ଛାଇ';

  @override
  String get styleAnime => 'ଆନିମେ';

  @override
  String get styleAnimeDesc => 'ଜାପାନୀ ଆନିମେ ଚିତ୍ର';

  @override
  String get styleFlat => 'ଫ୍ଲାଟ୍ ଭେକ୍ଟର୍';

  @override
  String get styleFlatDesc => 'ସମତଳ ରଙ୍ଗ ଓ ପରିଷ୍କାର ଆକାର';

  @override
  String get styleUkiyoe => 'ଉକିୟୋ-ଏ';

  @override
  String get styleUkiyoeDesc => 'ଜାପାନୀ କାଠ ଛାପା';

  @override
  String get styleMucha => 'ଆର୍ଟ ନୁଭୋ (ମୁଖା)';

  @override
  String get styleMuchaDesc => 'ସୁନେଲି ଛୁଆଁ ସହ ଅଳଙ୍କୃତ ଆର୍ଟ ନୁଭୋ';

  @override
  String get styleVanGogh => 'ଭ୍ୟାନ୍ ଗଗ୍';

  @override
  String get styleVanGoghDesc => 'ପୋଷ୍ଟ-ଇମ୍ପ୍ରେସନିଷ୍ଟ ଘୂର୍ଣ୍ଣି ଟାଣ';

  @override
  String get langAr => 'ଆରବୀ';

  @override
  String get langCs => 'ଚେକ୍';

  @override
  String get langDe => 'ଜର୍ମାନ';

  @override
  String get langEl => 'ଗ୍ରୀକ୍';

  @override
  String get langEn => 'ଇଂରାଜୀ';

  @override
  String get langEs419 => 'ସ୍ପାନିଶ୍';

  @override
  String get langFr => 'ଫ୍ରେଞ୍ଚ';

  @override
  String get langHe => 'ହିବ୍ରୁ';

  @override
  String get langHi => 'ହିନ୍ଦୀ';

  @override
  String get langId => 'ଇଣ୍ଡୋନେସୀୟ';

  @override
  String get langJa => 'ଜାପାନୀ';

  @override
  String get langKo => 'କୋରିଆନ୍';

  @override
  String get langPtBR => 'ପର୍ତ୍ତୁଗୀଜ୍';

  @override
  String get langRu => 'ରୁଷୀୟ';

  @override
  String get langTr => 'ତୁର୍କୀ';

  @override
  String get langVi => 'ଭିଏତନାମୀ';

  @override
  String get langZhCN => 'ଚାଇନିଜ୍';
}
