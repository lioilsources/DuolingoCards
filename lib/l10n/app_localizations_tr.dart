// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Deste Mağazası';

  @override
  String get homeEmptyTitle => 'Henüz deste yok';

  @override
  String get homeReorderHint =>
      'Sırayı değiştirmek için desteye uzun basıp sürükleyin';

  @override
  String get homeBrowseStore => 'Deste Mağazasına göz at';

  @override
  String get homeDownloadingDecks => 'Desteleriniz hazırlanıyor…';

  @override
  String get badgeFree => 'Ücretsiz';

  @override
  String get badgeUnlocked => 'Açıldı';

  @override
  String get badgePurchased => 'Satın alındı';

  @override
  String get badgePaidDeck => 'Ücretli deste';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kart',
      one: '1 kart',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards kart',
      one: '1 kart',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs dil',
      one: '1 dil',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count biliniyor';
  }

  @override
  String legendLearning(int count) {
    return '$count öğreniliyor';
  }

  @override
  String legendUnknown(int count) {
    return '$count bilinmiyor';
  }

  @override
  String get storeTitle => 'Deste Mağazası';

  @override
  String get storeRestorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get storeSearchHint => 'Deste ara…';

  @override
  String storeLoadError(String error) {
    return 'Desteler yüklenemedi: $error';
  }

  @override
  String get storeNoDecks => 'Kullanılabilir deste yok.';

  @override
  String get storeNothingFound => 'Hiçbir şey bulunamadı.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get buy => 'Satın al';

  @override
  String buyFor(String price) {
    return '$price karşılığında al';
  }

  @override
  String get add => 'Ekle';

  @override
  String get addFree => 'Ücretsiz ekle';

  @override
  String get back => 'Geri';

  @override
  String get previous => 'Önceki';

  @override
  String get next => 'Sonraki';

  @override
  String get study => 'Çalış';

  @override
  String get download => 'İndir';

  @override
  String get confirmLanguagesLabel => 'Diller';

  @override
  String get styleSectionTitle => 'Görsel stili';

  @override
  String get confirmBuyNote =>
      'Satın alma tüm desteyi açar — her dili ve her stili. Bu kombinasyon ana ekranınıza eklenecek.';

  @override
  String get confirmAddNote =>
      'Bu kombinasyon ana ekranınıza eklenecek. İstediğiniz zaman başka bir dil veya stil ekleyebilirsiniz.';

  @override
  String get purchaseFailedToStart => 'Satın alma başlatılamadı.';

  @override
  String get addedToHome => 'Ana ekranınıza eklendi.';

  @override
  String get downloadFailed => 'İndirme başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get deckNotPurchased => 'Bu deste satın alınmadı.';

  @override
  String downloading(int percent) {
    return 'İndiriliyor… %$percent';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etkin',
      one: '1 etkin',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Biliyorum';

  @override
  String get pickerLearning => 'Öğreniyorum';

  @override
  String get reportIssue => 'Sorun bildir';

  @override
  String get issueTranslation => 'Çeviri';

  @override
  String get issueImage => 'Görsel';

  @override
  String get issuePronunciation => 'Telaffuz';

  @override
  String get issueMeaning => 'Anlam / bilgiler';

  @override
  String get issueOther => 'Diğer';

  @override
  String get feedbackCommentHint => 'Sorun ne? (isteğe bağlı)';

  @override
  String get feedbackSend => 'E-postayla gönder';

  @override
  String feedbackNoMailApp(String email) {
    return 'E-posta uygulaması yok. Bildirim panoya kopyalandı — lütfen $email adresine gönderin.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Kart sorunu $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Deste: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kart: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Diller: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Gösterilen: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Stil: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Sorun türü: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Alıcı: $email';
  }

  @override
  String get pronounce => 'Seslendir';

  @override
  String get installVoice => 'Ses yükle';

  @override
  String noVoiceInstalled(String lang) {
    return '\"$lang\" için yüklü bir ses yok. Ayarlar → Erişilebilirlik → Seslendirilen İçerik → Sesler bölümünden bir ses ekleyip tekrar deneyin.';
  }

  @override
  String get playPronunciation => 'Telaffuzu dinle';

  @override
  String get swipeNext => 'SONRAKİ';

  @override
  String get swipeBack => 'GERİ';

  @override
  String get showTranslation => 'Çeviriyi göster';

  @override
  String get showOriginal => 'Orijinali göster';

  @override
  String get noCards => 'Kart yok';

  @override
  String get deckHasNoCards => 'Bu destede kart yok.';

  @override
  String get flashcards => 'Kartlar';

  @override
  String get stylePhoto => 'Fotoğraf';

  @override
  String get stylePhotoDesc => 'Net fotoğraf, gerçeğe en yakın';

  @override
  String get styleInk => 'Fırça ve mürekkep';

  @override
  String get styleInkDesc => 'Fırça darbeleri, boş kâğıt, tek renk vurgu';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Renkli kâğıt üzerine kuru pastel';

  @override
  String get styleWatercolor => 'Suluboya';

  @override
  String get styleWatercolorDesc => 'Yayılan renkler, altından görünen kâğıt';

  @override
  String get styleFlag => 'Bayraklar';

  @override
  String get styleFlagDesc => 'Gerçek ulusal bayraklar';

  @override
  String get stylePonyCartoon => 'Çizgi film';

  @override
  String get stylePonyCartoonDesc => 'Renkli çizgi film illüstrasyonu';

  @override
  String get styleStorybook => 'Masal kitabı';

  @override
  String get styleStorybookDesc => 'Yumuşak kitap illüstrasyonu';

  @override
  String get stylePonyWatercolor => 'Suluboya – yumuşak';

  @override
  String get stylePonyWatercolorDesc => 'Yumuşak suluboya tablo';

  @override
  String get stylePonyOil => 'Yağlıboya';

  @override
  String get stylePonyOilDesc => 'Tuval üzerinde kalın fırça darbeleri';

  @override
  String get styleIllustriousOil => 'Yağlıboya – empasto';

  @override
  String get styleIllustriousOilDesc => 'Kalın empasto boya, ışık-gölge';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Japon anime çizimi';

  @override
  String get styleFlat => 'Düz vektör';

  @override
  String get styleFlatDesc => 'Düz renkler ve temiz şekiller';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Japon ahşap baskısı';

  @override
  String get styleMucha => 'Art Nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Altın detaylı süslü art nouveau';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Post-empresyonist girdaplı fırça darbeleri';

  @override
  String get langAr => 'Arapça';

  @override
  String get langCs => 'Çekçe';

  @override
  String get langDe => 'Almanca';

  @override
  String get langEl => 'Yunanca';

  @override
  String get langEn => 'İngilizce';

  @override
  String get langEs419 => 'İspanyolca';

  @override
  String get langFr => 'Fransızca';

  @override
  String get langHe => 'İbranice';

  @override
  String get langHi => 'Hintçe';

  @override
  String get langId => 'Endonezce';

  @override
  String get langJa => 'Japonca';

  @override
  String get langKo => 'Korece';

  @override
  String get langPtBR => 'Portekizce';

  @override
  String get langRu => 'Rusça';

  @override
  String get langTr => 'Türkçe';

  @override
  String get langVi => 'Vietnamca';

  @override
  String get langZhCN => 'Çince';
}
