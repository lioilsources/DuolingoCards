// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'ડેક સ્ટોર';

  @override
  String get homeEmptyTitle => 'હજી કોઈ ડેક નથી';

  @override
  String get homeReorderHint => 'ક્રમ બદલવા માટે ડેકને દબાવી રાખો અને ખેંચો';

  @override
  String get homeBrowseStore => 'ડેક સ્ટોર જુઓ';

  @override
  String get homeDownloadingDecks => 'તમારા ડેક તૈયાર થઈ રહ્યા છે…';

  @override
  String get badgeFree => 'મફત';

  @override
  String get badgeUnlocked => 'અનલૉક કરેલ';

  @override
  String get badgePurchased => 'ખરીદેલ';

  @override
  String get badgePaidDeck => 'પેઇડ ડેક';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count કાર્ડ',
      one: '1 કાર્ડ',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards કાર્ડ',
      one: '1 કાર્ડ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs ભાષાઓ',
      one: '1 ભાષા',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count જાણીતા';
  }

  @override
  String legendLearning(int count) {
    return '$count શીખી રહ્યા છો';
  }

  @override
  String legendUnknown(int count) {
    return '$count અજાણ્યા';
  }

  @override
  String get storeTitle => 'ડેક સ્ટોર';

  @override
  String get storeRestorePurchases => 'ખરીદીઓ પુનઃસ્થાપિત કરો';

  @override
  String get storeSearchHint => 'ડેક શોધો…';

  @override
  String storeLoadError(String error) {
    return 'ડેક લોડ થઈ શક્યા નહીં: $error';
  }

  @override
  String get storeNoDecks => 'કોઈ ડેક ઉપલબ્ધ નથી.';

  @override
  String get storeNothingFound => 'કંઈ મળ્યું નહીં.';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get buy => 'ખરીદો';

  @override
  String buyFor(String price) {
    return '$priceમાં ખરીદો';
  }

  @override
  String get add => 'ઉમેરો';

  @override
  String get addFree => 'મફતમાં ઉમેરો';

  @override
  String get back => 'પાછળ';

  @override
  String get previous => 'પાછલું';

  @override
  String get next => 'આગળ';

  @override
  String get study => 'અભ્યાસ કરો';

  @override
  String get download => 'ડાઉનલોડ કરો';

  @override
  String get confirmLanguagesLabel => 'ભાષાઓ';

  @override
  String get styleSectionTitle => 'ચિત્ર શૈલી';

  @override
  String get confirmBuyNote =>
      'ખરીદીથી આખો ડેક અનલૉક થાય છે — દરેક ભાષા અને દરેક શૈલી. આ સંયોજન તમારી હોમ સ્ક્રીન પર ઉમેરાશે.';

  @override
  String get confirmAddNote =>
      'આ સંયોજન તમારી હોમ સ્ક્રીન પર ઉમેરાશે. તમે ગમે ત્યારે બીજી ભાષા કે શૈલી ઉમેરી શકો છો.';

  @override
  String get purchaseFailedToStart => 'ખરીદી શરૂ થઈ શકી નહીં.';

  @override
  String get addedToHome => 'હોમ સ્ક્રીન પર ઉમેર્યું.';

  @override
  String get downloadFailed => 'ડાઉનલોડ નિષ્ફળ ગયું. કૃપા કરી ફરી પ્રયાસ કરો.';

  @override
  String get deckNotPurchased => 'આ ડેક ખરીદાયો નથી.';

  @override
  String downloading(int percent) {
    return 'ડાઉનલોડ થઈ રહ્યું છે… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count સક્રિય',
      one: '1 સક્રિય',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'મને આવડે છે';

  @override
  String get pickerLearning => 'શીખું છું';

  @override
  String get reportIssue => 'સમસ્યાની જાણ કરો';

  @override
  String get issueTranslation => 'અનુવાદ';

  @override
  String get issueImage => 'ચિત્ર';

  @override
  String get issuePronunciation => 'ઉચ્ચાર';

  @override
  String get issueMeaning => 'અર્થ / હકીકતો';

  @override
  String get issueOther => 'અન્ય';

  @override
  String get feedbackCommentHint => 'શું ખોટું છે? (વૈકલ્પિક)';

  @override
  String get feedbackSend => 'ઈ-મેલથી મોકલો';

  @override
  String feedbackNoMailApp(String email) {
    return 'કોઈ ઈ-મેલ ઍપ ઉપલબ્ધ નથી. રિપોર્ટ ક્લિપબોર્ડ પર કૉપિ થયો છે — કૃપા કરી તેને $email પર મોકલો.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] કાર્ડમાં સમસ્યા $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'ડેક: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'કાર્ડ: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'ભાષાઓ: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'બતાવેલું: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'શૈલી: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'સમસ્યાનો પ્રકાર: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'પ્રતિ: $email';
  }

  @override
  String get pronounce => 'ઉચ્ચાર કરો';

  @override
  String get installVoice => 'અવાજ ઇન્સ્ટોલ કરો';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\" માટે કોઈ અવાજ ઇન્સ્ટોલ નથી. સેટિંગ્સ → ઍક્સેસિબિલિટી → સ્પોકન કન્ટેન્ટ → વૉઇસિસમાં એક ઉમેરો, પછી ફરી પ્રયાસ કરો.';
  }

  @override
  String get playPronunciation => 'ઉચ્ચાર સાંભળો';

  @override
  String get swipeNext => 'આગળ';

  @override
  String get swipeBack => 'પાછળ';

  @override
  String get showTranslation => 'અનુવાદ બતાવો';

  @override
  String get showOriginal => 'મૂળ બતાવો';

  @override
  String get noCards => 'કોઈ કાર્ડ નથી';

  @override
  String get deckHasNoCards => 'આ ડેકમાં કોઈ કાર્ડ નથી.';

  @override
  String get flashcards => 'ફ્લેશકાર્ડ';

  @override
  String get stylePhoto => 'ફોટો';

  @override
  String get stylePhotoDesc => 'સ્પષ્ટ ફોટોગ્રાફ, વાસ્તવિકતાની સૌથી નજીક';

  @override
  String get styleInk => 'બ્રશ અને શાહી';

  @override
  String get styleInkDesc => 'બ્રશના લસરકા, કોરો કાગળ, એક રંગની ઝલક';

  @override
  String get stylePastel => 'પેસ્ટલ';

  @override
  String get stylePastelDesc => 'રંગીન કાગળ પર સૂકો પેસ્ટલ';

  @override
  String get styleWatercolor => 'જળરંગ';

  @override
  String get styleWatercolorDesc => 'ફેલાતા જળરંગ, કાગળ દેખાય છે';

  @override
  String get styleFlag => 'ધ્વજ';

  @override
  String get styleFlagDesc => 'સાચા રાષ્ટ્રીય ધ્વજ';

  @override
  String get stylePonyCartoon => 'કાર્ટૂન';

  @override
  String get stylePonyCartoonDesc => 'રંગબેરંગી કાર્ટૂન ચિત્ર';

  @override
  String get styleStorybook => 'વાર્તાનું પુસ્તક';

  @override
  String get styleStorybookDesc => 'નરમ પુસ્તક ચિત્ર';

  @override
  String get stylePonyWatercolor => 'જળરંગ – નરમ';

  @override
  String get stylePonyWatercolorDesc => 'નરમ જળરંગ ચિત્ર';

  @override
  String get stylePonyOil => 'તૈલચિત્ર';

  @override
  String get stylePonyOilDesc => 'કૅનવાસ પર જાડા બ્રશ લસરકા';

  @override
  String get styleIllustriousOil => 'તૈલરંગ – ઇમ્પાસ્ટો';

  @override
  String get styleIllustriousOilDesc => 'ઘટ્ટ ઇમ્પાસ્ટો રંગ, પ્રકાશ-છાયા';

  @override
  String get styleAnime => 'એનિમે';

  @override
  String get styleAnimeDesc => 'જાપાની એનિમે ચિત્ર';

  @override
  String get styleFlat => 'ફ્લેટ વેક્ટર';

  @override
  String get styleFlatDesc => 'સપાટ રંગો અને સ્વચ્છ આકારો';

  @override
  String get styleUkiyoe => 'ઉકિયો-એ';

  @override
  String get styleUkiyoeDesc => 'જાપાની લાકડાની છાપ';

  @override
  String get styleMucha => 'આર્ટ નુવો (મુખા)';

  @override
  String get styleMuchaDesc => 'સોનેરી ઝલક સાથે સુશોભિત આર્ટ નુવો';

  @override
  String get styleVanGogh => 'વેન ગો';

  @override
  String get styleVanGoghDesc => 'પોસ્ટ-ઇમ્પ્રેશનિસ્ટ ઘૂમરાતા લસરકા';

  @override
  String get langAr => 'અરબી';

  @override
  String get langCs => 'ચેક';

  @override
  String get langDe => 'જર્મન';

  @override
  String get langEl => 'ગ્રીક';

  @override
  String get langEn => 'અંગ્રેજી';

  @override
  String get langEs419 => 'સ્પેનિશ';

  @override
  String get langFr => 'ફ્રેન્ચ';

  @override
  String get langHe => 'હિબ્રૂ';

  @override
  String get langHi => 'હિન્દી';

  @override
  String get langId => 'ઇન્ડોનેશિયન';

  @override
  String get langJa => 'જાપાની';

  @override
  String get langKo => 'કોરિયન';

  @override
  String get langPtBR => 'પોર્ટુગીઝ';

  @override
  String get langRu => 'રશિયન';

  @override
  String get langTr => 'તુર્કી';

  @override
  String get langVi => 'વિયેતનામી';

  @override
  String get langZhCN => 'ચાઇનીઝ';
}
