// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Kedai Dek';

  @override
  String get homeEmptyTitle => 'Belum ada dek';

  @override
  String get homeReorderHint =>
      'Tekan lama pada dek dan seret untuk menyusun semula';

  @override
  String get homeBrowseStore => 'Layari Kedai Dek';

  @override
  String get homeDownloadingDecks => 'Menyediakan dek anda…';

  @override
  String get badgeFree => 'Percuma';

  @override
  String get badgeUnlocked => 'Dibuka';

  @override
  String get badgePurchased => 'Dibeli';

  @override
  String get badgePaidDeck => 'Dek berbayar';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kad',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards kad',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs bahasa',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count diketahui';
  }

  @override
  String legendLearning(int count) {
    return '$count sedang dipelajari';
  }

  @override
  String legendUnknown(int count) {
    return '$count belum diketahui';
  }

  @override
  String get storeTitle => 'Kedai Dek';

  @override
  String get storeRestorePurchases => 'Pulihkan Pembelian';

  @override
  String get storeSearchHint => 'Cari dek…';

  @override
  String storeLoadError(String error) {
    return 'Tidak dapat memuatkan dek: $error';
  }

  @override
  String get storeNoDecks => 'Tiada dek tersedia.';

  @override
  String get storeNothingFound => 'Tiada apa-apa ditemui.';

  @override
  String get retry => 'Cuba lagi';

  @override
  String get buy => 'Beli';

  @override
  String buyFor(String price) {
    return 'Beli dengan $price';
  }

  @override
  String get add => 'Tambah';

  @override
  String get addFree => 'Tambah secara percuma';

  @override
  String get back => 'Kembali';

  @override
  String get previous => 'Sebelumnya';

  @override
  String get next => 'Seterusnya';

  @override
  String get study => 'Belajar';

  @override
  String get download => 'Muat turun';

  @override
  String get confirmLanguagesLabel => 'Bahasa';

  @override
  String get styleSectionTitle => 'Gaya imej';

  @override
  String get confirmBuyNote =>
      'Pembelian membuka seluruh dek — setiap bahasa dan setiap gaya. Gabungan ini akan ditambah pada skrin utama anda.';

  @override
  String get confirmAddNote =>
      'Gabungan ini akan ditambah pada skrin utama anda. Anda boleh menambah bahasa atau gaya lain pada bila-bila masa.';

  @override
  String get purchaseFailedToStart => 'Pembelian tidak dapat dimulakan.';

  @override
  String get addedToHome => 'Ditambah pada skrin utama anda.';

  @override
  String get downloadFailed => 'Muat turun gagal. Sila cuba lagi.';

  @override
  String get deckNotPurchased => 'Dek ini belum dibeli.';

  @override
  String downloading(int percent) {
    return 'Memuat turun… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktif',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Saya tahu';

  @override
  String get pickerLearning => 'Sedang belajar';

  @override
  String get reportIssue => 'Laporkan masalah';

  @override
  String get issueTranslation => 'Terjemahan';

  @override
  String get issueImage => 'Imej';

  @override
  String get issuePronunciation => 'Sebutan';

  @override
  String get issueMeaning => 'Maksud / fakta';

  @override
  String get issueOther => 'Lain-lain';

  @override
  String get feedbackCommentHint => 'Apa yang salah? (pilihan)';

  @override
  String get feedbackSend => 'Hantar melalui e-mel';

  @override
  String feedbackNoMailApp(String email) {
    return 'Tiada apl e-mel tersedia. Laporan telah disalin ke papan klip — sila hantar ke $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Masalah kad $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Dek: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kad: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Bahasa: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Dipaparkan: $foreign / $native';
  }

  @override
  String feedbackBodyStyle(String style) {
    return 'Gaya: $style';
  }

  @override
  String feedbackBodyIssue(String issue) {
    return 'Jenis masalah: $issue';
  }

  @override
  String feedbackClipboardTo(String email) {
    return 'Kepada: $email';
  }

  @override
  String get pronounce => 'Sebut';

  @override
  String get installVoice => 'Pasang suara';

  @override
  String noVoiceInstalled(String lang) {
    return 'Tiada suara untuk \"$lang\" dipasang. Tambah satu dalam Tetapan → Kebolehcapaian → Kandungan Dituturkan → Suara, kemudian cuba lagi.';
  }

  @override
  String get playPronunciation => 'Main sebutan';

  @override
  String get swipeNext => 'SETERUSNYA';

  @override
  String get swipeBack => 'KEMBALI';

  @override
  String get showTranslation => 'Tunjukkan terjemahan';

  @override
  String get showOriginal => 'Tunjukkan asal';

  @override
  String get noCards => 'Tiada kad';

  @override
  String get deckHasNoCards => 'Dek ini tiada kad.';

  @override
  String get flashcards => 'Kad imbas';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc => 'Gambar tajam, paling hampir dengan realiti';

  @override
  String get styleInk => 'Berus dan dakwat';

  @override
  String get styleInkDesc => 'Sapuan berus, kertas kosong, satu aksen warna';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Pastel kering pada kertas berwarna';

  @override
  String get styleWatercolor => 'Cat air';

  @override
  String get styleWatercolorDesc =>
      'Sapuan cat air yang meresap, kertas kelihatan';

  @override
  String get styleFlag => 'Bendera';

  @override
  String get styleFlagDesc => 'Bendera kebangsaan yang sebenar';

  @override
  String get stylePonyCartoon => 'Kartun';

  @override
  String get stylePonyCartoonDesc => 'Ilustrasi kartun berwarna-warni';

  @override
  String get styleStorybook => 'Buku cerita';

  @override
  String get styleStorybookDesc => 'Ilustrasi buku yang lembut';

  @override
  String get stylePonyWatercolor => 'Cat air – lembut';

  @override
  String get stylePonyWatercolorDesc => 'Lukisan cat air yang lembut';

  @override
  String get stylePonyOil => 'Lukisan minyak';

  @override
  String get stylePonyOilDesc => 'Sapuan berus tebal pada kanvas';

  @override
  String get styleIllustriousOil => 'Minyak – impasto';

  @override
  String get styleIllustriousOilDesc => 'Cat impasto tebal, chiaroscuro';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Lukisan anime Jepun';

  @override
  String get styleFlat => 'Vektor rata';

  @override
  String get styleFlatDesc => 'Warna rata dan bentuk kemas';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Cetakan blok kayu Jepun';

  @override
  String get styleMucha => 'Art Nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Art nouveau berhias dengan aksen emas';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Sapuan berpusar pasca-impresionis';

  @override
  String get langAr => 'Arab';

  @override
  String get langCs => 'Czech';

  @override
  String get langDe => 'Jerman';

  @override
  String get langEl => 'Greek';

  @override
  String get langEn => 'Inggeris';

  @override
  String get langEs419 => 'Sepanyol';

  @override
  String get langFr => 'Perancis';

  @override
  String get langHe => 'Ibrani';

  @override
  String get langHi => 'Hindi';

  @override
  String get langId => 'Indonesia';

  @override
  String get langJa => 'Jepun';

  @override
  String get langKo => 'Korea';

  @override
  String get langPtBR => 'Portugis';

  @override
  String get langRu => 'Rusia';

  @override
  String get langTr => 'Turki';

  @override
  String get langVi => 'Vietnam';

  @override
  String get langZhCN => 'Cina';
}
