// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Cửa hàng bộ thẻ';

  @override
  String get homeEmptyTitle => 'Chưa có bộ thẻ nào';

  @override
  String get homeReorderHint => 'Nhấn giữ một bộ thẻ rồi kéo để sắp xếp lại';

  @override
  String get homeBrowseStore => 'Xem cửa hàng bộ thẻ';

  @override
  String get homeDownloadingDecks => 'Đang chuẩn bị bộ thẻ của bạn…';

  @override
  String get badgeFree => 'Miễn phí';

  @override
  String get badgeUnlocked => 'Đã mở khóa';

  @override
  String get badgePurchased => 'Đã mua';

  @override
  String get badgePaidDeck => 'Bộ thẻ trả phí';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
      one: '1 thẻ',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards thẻ',
      one: '1 thẻ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs ngôn ngữ',
      one: '1 ngôn ngữ',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count đã biết';
  }

  @override
  String legendLearning(int count) {
    return '$count đang học';
  }

  @override
  String legendUnknown(int count) {
    return '$count chưa biết';
  }

  @override
  String get storeTitle => 'Cửa hàng bộ thẻ';

  @override
  String get storeRestorePurchases => 'Khôi phục giao dịch mua';

  @override
  String get storeSearchHint => 'Tìm bộ thẻ…';

  @override
  String storeLoadError(String error) {
    return 'Không thể tải bộ thẻ: $error';
  }

  @override
  String get storeNoDecks => 'Không có bộ thẻ nào.';

  @override
  String get storeNothingFound => 'Không tìm thấy gì.';

  @override
  String get retry => 'Thử lại';

  @override
  String get buy => 'Mua';

  @override
  String buyFor(String price) {
    return 'Mua với giá $price';
  }

  @override
  String get add => 'Thêm';

  @override
  String get addFree => 'Thêm miễn phí';

  @override
  String get back => 'Quay lại';

  @override
  String get previous => 'Trước';

  @override
  String get next => 'Tiếp';

  @override
  String get study => 'Học';

  @override
  String get download => 'Tải về';

  @override
  String get confirmLanguagesLabel => 'Ngôn ngữ';

  @override
  String get styleSectionTitle => 'Phong cách hình ảnh';

  @override
  String get confirmBuyNote =>
      'Mua sẽ mở khóa toàn bộ bộ thẻ — mọi ngôn ngữ và mọi phong cách. Tổ hợp này sẽ được thêm vào màn hình chính.';

  @override
  String get confirmAddNote =>
      'Tổ hợp này sẽ được thêm vào màn hình chính. Bạn có thể thêm ngôn ngữ hoặc phong cách khác bất cứ lúc nào.';

  @override
  String get purchaseFailedToStart => 'Không thể bắt đầu giao dịch mua.';

  @override
  String get addedToHome => 'Đã thêm vào màn hình chính.';

  @override
  String get downloadFailed => 'Tải về thất bại. Vui lòng thử lại.';

  @override
  String get deckNotPurchased => 'Bộ thẻ này chưa được mua.';

  @override
  String downloading(int percent) {
    return 'Đang tải… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đang dùng',
      one: '1 đang dùng',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Đã biết';

  @override
  String get pickerLearning => 'Đang học';

  @override
  String get reportIssue => 'Báo cáo sự cố';

  @override
  String get issueTranslation => 'Bản dịch';

  @override
  String get issueImage => 'Hình ảnh';

  @override
  String get issuePronunciation => 'Phát âm';

  @override
  String get issueMeaning => 'Nghĩa / thông tin';

  @override
  String get issueOther => 'Khác';

  @override
  String get feedbackCommentHint => 'Có gì sai? (không bắt buộc)';

  @override
  String get feedbackSend => 'Gửi qua email';

  @override
  String feedbackNoMailApp(String email) {
    return 'Không có ứng dụng email. Báo cáo đã được sao chép vào bộ nhớ tạm — vui lòng gửi đến $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Sự cố thẻ $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Bộ thẻ: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Thẻ: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Ngôn ngữ: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Đã hiển thị: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Phong cách: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Loại sự cố: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Đến: $email';
  }

  @override
  String get pronounce => 'Phát âm';

  @override
  String get installVoice => 'Cài đặt giọng nói';

  @override
  String noVoiceInstalled(String lang) {
    return 'Chưa cài giọng nói cho \"$lang\". Hãy thêm trong Cài đặt → Trợ năng → Nội dung được đọc → Giọng nói, rồi thử lại.';
  }

  @override
  String get playPronunciation => 'Phát cách đọc';

  @override
  String get swipeNext => 'TIẾP';

  @override
  String get swipeBack => 'LẠI';

  @override
  String get showTranslation => 'Hiện bản dịch';

  @override
  String get showOriginal => 'Hiện bản gốc';

  @override
  String get noCards => 'Không có thẻ';

  @override
  String get deckHasNoCards => 'Bộ thẻ này không có thẻ nào.';

  @override
  String get flashcards => 'Thẻ ghi nhớ';

  @override
  String get stylePhoto => 'Ảnh chụp';

  @override
  String get stylePhotoDesc => 'Ảnh sắc nét, gần với thực tế nhất';

  @override
  String get styleInk => 'Bút lông và mực';

  @override
  String get styleInkDesc => 'Nét cọ, giấy trơn, một điểm nhấn màu';

  @override
  String get stylePastel => 'Phấn màu';

  @override
  String get stylePastelDesc => 'Phấn khô trên giấy màu';

  @override
  String get styleWatercolor => 'Màu nước';

  @override
  String get styleWatercolorDesc => 'Mảng màu loang, lộ nền giấy';

  @override
  String get styleFlag => 'Quốc kỳ';

  @override
  String get styleFlagDesc => 'Quốc kỳ thật của các nước';

  @override
  String get stylePonyCartoon => 'Hoạt hình';

  @override
  String get stylePonyCartoonDesc => 'Minh họa hoạt hình đầy màu sắc';

  @override
  String get styleStorybook => 'Sách truyện';

  @override
  String get styleStorybookDesc => 'Minh họa sách nhẹ nhàng';

  @override
  String get stylePonyWatercolor => 'Màu nước – dịu';

  @override
  String get stylePonyWatercolorDesc => 'Tranh màu nước dịu nhẹ';

  @override
  String get stylePonyOil => 'Tranh sơn dầu';

  @override
  String get stylePonyOilDesc => 'Nét cọ dày trên vải canvas';

  @override
  String get styleIllustriousOil => 'Sơn dầu – impasto';

  @override
  String get styleIllustriousOilDesc =>
      'Lớp sơn impasto dày, tương phản sáng tối';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Tranh vẽ anime Nhật Bản';

  @override
  String get styleFlat => 'Vector phẳng';

  @override
  String get styleFlatDesc => 'Màu phẳng và hình khối gọn gàng';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Tranh khắc gỗ Nhật Bản';

  @override
  String get styleMucha => 'Art Nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Art nouveau trang trí với điểm nhấn vàng';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Nét cọ xoáy hậu ấn tượng';

  @override
  String get langAr => 'Tiếng Ả Rập';

  @override
  String get langCs => 'Tiếng Séc';

  @override
  String get langDe => 'Tiếng Đức';

  @override
  String get langEl => 'Tiếng Hy Lạp';

  @override
  String get langEn => 'Tiếng Anh';

  @override
  String get langEs419 => 'Tiếng Tây Ban Nha';

  @override
  String get langFr => 'Tiếng Pháp';

  @override
  String get langHe => 'Tiếng Do Thái';

  @override
  String get langHi => 'Tiếng Hindi';

  @override
  String get langId => 'Tiếng Indonesia';

  @override
  String get langJa => 'Tiếng Nhật';

  @override
  String get langKo => 'Tiếng Hàn';

  @override
  String get langPtBR => 'Tiếng Bồ Đào Nha';

  @override
  String get langRu => 'Tiếng Nga';

  @override
  String get langTr => 'Tiếng Thổ Nhĩ Kỳ';

  @override
  String get langVi => 'Tiếng Việt';

  @override
  String get langZhCN => 'Tiếng Trung';
}
