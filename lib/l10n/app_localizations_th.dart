// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'ร้านชุดการ์ด';

  @override
  String get homeEmptyTitle => 'ยังไม่มีชุดการ์ด';

  @override
  String get homeReorderHint => 'กดค้างที่ชุดการ์ดแล้วลากเพื่อจัดลำดับ';

  @override
  String get homeBrowseStore => 'เลือกดูร้านชุดการ์ด';

  @override
  String get homeDownloadingDecks => 'กำลังเตรียมชุดการ์ดของคุณ…';

  @override
  String get badgeFree => 'ฟรี';

  @override
  String get badgeUnlocked => 'ปลดล็อกแล้ว';

  @override
  String get badgePurchased => 'ซื้อแล้ว';

  @override
  String get badgePaidDeck => 'ชุดการ์ดแบบชำระเงิน';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count การ์ด',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards การ์ด',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs ภาษา',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return 'รู้แล้ว $count';
  }

  @override
  String legendLearning(int count) {
    return 'กำลังเรียน $count';
  }

  @override
  String legendUnknown(int count) {
    return 'ยังไม่รู้ $count';
  }

  @override
  String get storeTitle => 'ร้านชุดการ์ด';

  @override
  String get storeRestorePurchases => 'กู้คืนการซื้อ';

  @override
  String get storeSearchHint => 'ค้นหาชุดการ์ด…';

  @override
  String storeLoadError(String error) {
    return 'โหลดชุดการ์ดไม่ได้: $error';
  }

  @override
  String get storeNoDecks => 'ไม่มีชุดการ์ด';

  @override
  String get storeNothingFound => 'ไม่พบผลลัพธ์';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get buy => 'ซื้อ';

  @override
  String buyFor(String price) {
    return 'ซื้อในราคา $price';
  }

  @override
  String get add => 'เพิ่ม';

  @override
  String get addFree => 'เพิ่มฟรี';

  @override
  String get back => 'ย้อนกลับ';

  @override
  String get previous => 'ก่อนหน้า';

  @override
  String get next => 'ถัดไป';

  @override
  String get study => 'เรียน';

  @override
  String get download => 'ดาวน์โหลด';

  @override
  String get confirmLanguagesLabel => 'ภาษา';

  @override
  String get styleSectionTitle => 'สไตล์ภาพ';

  @override
  String get confirmBuyNote =>
      'การซื้อจะปลดล็อกทั้งชุด — ทุกภาษาและทุกสไตล์ ชุดผสมนี้จะถูกเพิ่มลงในหน้าหลักของคุณ';

  @override
  String get confirmAddNote =>
      'ชุดผสมนี้จะถูกเพิ่มลงในหน้าหลักของคุณ คุณเพิ่มภาษาหรือสไตล์อื่นได้ทุกเมื่อ';

  @override
  String get purchaseFailedToStart => 'ไม่สามารถเริ่มการซื้อได้';

  @override
  String get addedToHome => 'เพิ่มลงในหน้าหลักแล้ว';

  @override
  String get downloadFailed => 'ดาวน์โหลดไม่สำเร็จ โปรดลองอีกครั้ง';

  @override
  String get deckNotPurchased => 'ยังไม่ได้ซื้อชุดการ์ดนี้';

  @override
  String downloading(int percent) {
    return 'กำลังดาวน์โหลด… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ใช้งาน $count',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'รู้แล้ว';

  @override
  String get pickerLearning => 'กำลังเรียน';

  @override
  String get reportIssue => 'รายงานปัญหา';

  @override
  String get issueTranslation => 'คำแปล';

  @override
  String get issueImage => 'รูปภาพ';

  @override
  String get issuePronunciation => 'การออกเสียง';

  @override
  String get issueMeaning => 'ความหมาย / ข้อเท็จจริง';

  @override
  String get issueOther => 'อื่นๆ';

  @override
  String get feedbackCommentHint => 'มีอะไรผิด? (ไม่บังคับ)';

  @override
  String get feedbackSend => 'ส่งทางอีเมล';

  @override
  String feedbackNoMailApp(String email) {
    return 'ไม่มีแอปอีเมล คัดลอกรายงานไปยังคลิปบอร์ดแล้ว — โปรดส่งไปที่ $email';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] ปัญหาของการ์ด $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'ชุดการ์ด: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'การ์ด: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'ภาษา: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'ที่แสดง: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'สไตล์: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'ประเภทปัญหา: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'ถึง: $email';
  }

  @override
  String get pronounce => 'ออกเสียง';

  @override
  String get installVoice => 'ติดตั้งเสียง';

  @override
  String noVoiceInstalled(String lang) {
    return 'ยังไม่ได้ติดตั้งเสียงสำหรับ \"$lang\" เพิ่มได้ที่ การตั้งค่า → การช่วยการเข้าถึง → เนื้อหาที่พูด → เสียง แล้วลองอีกครั้ง';
  }

  @override
  String get playPronunciation => 'เล่นเสียงออกเสียง';

  @override
  String get swipeNext => 'ถัดไป';

  @override
  String get swipeBack => 'ย้อนกลับ';

  @override
  String get showTranslation => 'แสดงคำแปล';

  @override
  String get showOriginal => 'แสดงต้นฉบับ';

  @override
  String get noCards => 'ไม่มีการ์ด';

  @override
  String get deckHasNoCards => 'ชุดนี้ไม่มีการ์ด';

  @override
  String get flashcards => 'แฟลชการ์ด';

  @override
  String get stylePhoto => 'ภาพถ่าย';

  @override
  String get stylePhotoDesc => 'ภาพถ่ายคมชัด ใกล้เคียงของจริงที่สุด';

  @override
  String get styleInk => 'พู่กันและหมึก';

  @override
  String get styleInkDesc => 'ลายพู่กัน กระดาษเปล่า แต้มสีเดียว';

  @override
  String get stylePastel => 'สีชอล์ก';

  @override
  String get stylePastelDesc => 'สีชอล์กแห้งบนกระดาษสี';

  @override
  String get styleWatercolor => 'สีน้ำ';

  @override
  String get styleWatercolorDesc => 'สีน้ำซึมกระจาย เห็นเนื้อกระดาษ';

  @override
  String get styleFlag => 'ธง';

  @override
  String get styleFlagDesc => 'ธงชาติจริง';

  @override
  String get stylePonyCartoon => 'การ์ตูน';

  @override
  String get stylePonyCartoonDesc => 'ภาพประกอบการ์ตูนสีสันสดใส';

  @override
  String get styleStorybook => 'หนังสือนิทาน';

  @override
  String get styleStorybookDesc => 'ภาพประกอบหนังสือโทนนุ่ม';

  @override
  String get stylePonyWatercolor => 'สีน้ำ – นุ่มนวล';

  @override
  String get stylePonyWatercolorDesc => 'ภาพวาดสีน้ำนุ่มนวล';

  @override
  String get stylePonyOil => 'สีน้ำมัน';

  @override
  String get stylePonyOilDesc => 'ฝีแปรงหนาบนผ้าใบ';

  @override
  String get styleIllustriousOil => 'สีน้ำมัน – อิมพาสโต';

  @override
  String get styleIllustriousOilDesc => 'สีหนาแบบอิมพาสโต แสงเงาเข้ม';

  @override
  String get styleAnime => 'อนิเมะ';

  @override
  String get styleAnimeDesc => 'ภาพวาดอนิเมะญี่ปุ่น';

  @override
  String get styleFlat => 'เวกเตอร์แบน';

  @override
  String get styleFlatDesc => 'สีเรียบและรูปทรงสะอาดตา';

  @override
  String get styleUkiyoe => 'อุกิโยะเอะ';

  @override
  String get styleUkiyoeDesc => 'ภาพพิมพ์แกะไม้ญี่ปุ่น';

  @override
  String get styleMucha => 'อาร์ตนูโว (มูคา)';

  @override
  String get styleMuchaDesc => 'อาร์ตนูโวลวดลายวิจิตรพร้อมแต้มสีทอง';

  @override
  String get styleVanGogh => 'แวนโก๊ะ';

  @override
  String get styleVanGoghDesc => 'ฝีแปรงหมุนวนแบบโพสต์อิมเพรสชันนิสม์';

  @override
  String get langAr => 'อาหรับ';

  @override
  String get langCs => 'เช็ก';

  @override
  String get langDe => 'เยอรมัน';

  @override
  String get langEl => 'กรีก';

  @override
  String get langEn => 'อังกฤษ';

  @override
  String get langEs419 => 'สเปน';

  @override
  String get langFr => 'ฝรั่งเศส';

  @override
  String get langHe => 'ฮีบรู';

  @override
  String get langHi => 'ฮินดี';

  @override
  String get langId => 'อินโดนีเซีย';

  @override
  String get langJa => 'ญี่ปุ่น';

  @override
  String get langKo => 'เกาหลี';

  @override
  String get langPtBR => 'โปรตุเกส';

  @override
  String get langRu => 'รัสเซีย';

  @override
  String get langTr => 'ตุรกี';

  @override
  String get langVi => 'เวียดนาม';

  @override
  String get langZhCN => 'จีน';
}
