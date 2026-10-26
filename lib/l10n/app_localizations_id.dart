// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Lexify';

  @override
  String get homeStoreTooltip => 'Toko Dek';

  @override
  String get homeEmptyTitle => 'Belum ada dek';

  @override
  String get homeReorderHint =>
      'Tekan lama dek lalu seret untuk mengubah urutan';

  @override
  String get homeBrowseStore => 'Jelajahi Toko Dek';

  @override
  String get homeDownloadingDecks => 'Menyiapkan dek kamu…';

  @override
  String get badgeFree => 'Gratis';

  @override
  String get badgeUnlocked => 'Terbuka';

  @override
  String get badgePurchased => 'Dibeli';

  @override
  String get badgePaidDeck => 'Dek berbayar';

  @override
  String tileCardsAndPair(int count, String l1, String l2) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kartu',
      one: '1 kartu',
    );
    return '$_temp0 · $l1 → $l2';
  }

  @override
  String tileCardsAndLanguages(int cards, int langs) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards kartu',
      one: '1 kartu',
    );
    String _temp1 = intl.Intl.pluralLogic(
      langs,
      locale: localeName,
      other: '$langs bahasa',
      one: '1 bahasa',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String legendKnown(int count) {
    return '$count dikuasai';
  }

  @override
  String legendLearning(int count) {
    return '$count dipelajari';
  }

  @override
  String legendUnknown(int count) {
    return '$count belum tahu';
  }

  @override
  String get storeTitle => 'Toko Dek';

  @override
  String get storeRestorePurchases => 'Pulihkan Pembelian';

  @override
  String get storeSearchHint => 'Cari dek…';

  @override
  String storeLoadError(String error) {
    return 'Tidak dapat memuat dek: $error';
  }

  @override
  String get storeNoDecks => 'Tidak ada dek yang tersedia.';

  @override
  String get storeNothingFound => 'Tidak ditemukan apa pun.';

  @override
  String get retry => 'Coba lagi';

  @override
  String get buy => 'Beli';

  @override
  String buyFor(String price) {
    return 'Beli seharga $price';
  }

  @override
  String get add => 'Tambah';

  @override
  String get addFree => 'Tambah gratis';

  @override
  String get back => 'Kembali';

  @override
  String get previous => 'Sebelumnya';

  @override
  String get next => 'Berikutnya';

  @override
  String get study => 'Belajar';

  @override
  String get download => 'Unduh';

  @override
  String get confirmLanguagesLabel => 'Bahasa';

  @override
  String get styleSectionTitle => 'Gaya gambar';

  @override
  String get confirmBuyNote =>
      'Pembelian membuka seluruh dek — semua bahasa dan semua gaya. Kombinasi ini akan ditambahkan ke layar utama.';

  @override
  String get confirmAddNote =>
      'Kombinasi ini akan ditambahkan ke layar utama. Kamu bisa menambah bahasa atau gaya lain kapan saja.';

  @override
  String get purchaseFailedToStart => 'Pembelian tidak dapat dimulai.';

  @override
  String get addedToHome => 'Ditambahkan ke layar utama.';

  @override
  String get downloadFailed => 'Unduhan gagal. Silakan coba lagi.';

  @override
  String get deckNotPurchased => 'Dek ini belum dibeli.';

  @override
  String downloading(int percent) {
    return 'Mengunduh… $percent%';
  }

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktif',
      one: '1 aktif',
    );
    return '$_temp0';
  }

  @override
  String get pickerIKnow => 'Sudah tahu';

  @override
  String get pickerLearning => 'Sedang belajar';

  @override
  String get reportIssue => 'Laporkan masalah';

  @override
  String get issueTranslation => 'Terjemahan';

  @override
  String get issueImage => 'Gambar';

  @override
  String get issuePronunciation => 'Pelafalan';

  @override
  String get issueMeaning => 'Arti / fakta';

  @override
  String get issueOther => 'Lainnya';

  @override
  String get feedbackCommentHint => 'Apa yang salah? (opsional)';

  @override
  String get feedbackSend => 'Kirim lewat email';

  @override
  String feedbackNoMailApp(String email) {
    return 'Tidak ada aplikasi email. Laporan sudah disalin ke papan klip — silakan kirim ke $email.';
  }

  @override
  String feedbackSubject(String key, String slug) {
    return '[Lexify] Masalah kartu $key ($slug)';
  }

  @override
  String feedbackBodyDeck(String slug, String version, String title) {
    return 'Dek: $slug v$version ($title)';
  }

  @override
  String feedbackBodyCard(String key) {
    return 'Kartu: $key';
  }

  @override
  String feedbackBodyLanguages(String l1, String l2) {
    return 'Bahasa: $l1 → $l2';
  }

  @override
  String feedbackBodyShown(String foreign, String native) {
    return 'Ditampilkan: $foreign / $native';
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
  String get pronounce => 'Ucapkan';

  @override
  String get installVoice => 'Pasang suara';

  @override
  String noVoiceInstalled(String lang) {
    return 'Belum ada suara untuk \"$lang\". Tambahkan di Pengaturan → Aksesibilitas → Konten Lisan → Suara, lalu coba lagi.';
  }

  @override
  String get playPronunciation => 'Putar pelafalan';

  @override
  String get swipeNext => 'LANJUT';

  @override
  String get swipeBack => 'KEMBALI';

  @override
  String get showTranslation => 'Tampilkan terjemahan';

  @override
  String get showOriginal => 'Tampilkan aslinya';

  @override
  String get noCards => 'Tidak ada kartu';

  @override
  String get deckHasNoCards => 'Dek ini tidak berisi kartu.';

  @override
  String get flashcards => 'Kartu';

  @override
  String get stylePhoto => 'Foto';

  @override
  String get stylePhotoDesc => 'Foto tajam, paling mirip aslinya';

  @override
  String get styleInk => 'Kuas dan tinta';

  @override
  String get styleInkDesc => 'Sapuan kuas, kertas polos, satu aksen warna';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get stylePastelDesc => 'Pastel kering di atas kertas berwarna';

  @override
  String get styleWatercolor => 'Cat air';

  @override
  String get styleWatercolorDesc =>
      'Sapuan warna mengalir, kertas tampak di baliknya';

  @override
  String get styleFlag => 'Bendera';

  @override
  String get styleFlagDesc => 'Bendera negara yang asli';

  @override
  String get stylePonyCartoon => 'Kartun';

  @override
  String get stylePonyCartoonDesc => 'Ilustrasi kartun penuh warna';

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
  String get stylePonyOilDesc => 'Sapuan kuas tebal di atas kanvas';

  @override
  String get styleIllustriousOil => 'Minyak – impasto';

  @override
  String get styleIllustriousOilDesc => 'Cat impasto tebal, terang-gelap';

  @override
  String get styleAnime => 'Anime';

  @override
  String get styleAnimeDesc => 'Gambar anime Jepang';

  @override
  String get styleFlat => 'Vektor datar';

  @override
  String get styleFlatDesc => 'Warna datar dan bentuk rapi';

  @override
  String get styleUkiyoe => 'Ukiyo-e';

  @override
  String get styleUkiyoeDesc => 'Cetak balok kayu Jepang';

  @override
  String get styleMucha => 'Art Nouveau (Mucha)';

  @override
  String get styleMuchaDesc => 'Art nouveau ornamental dengan aksen emas';

  @override
  String get styleVanGogh => 'Van Gogh';

  @override
  String get styleVanGoghDesc => 'Sapuan berpusar pasca-impresionis';

  @override
  String get langAr => 'Bahasa Arab';

  @override
  String get langCs => 'Bahasa Ceko';

  @override
  String get langDe => 'Bahasa Jerman';

  @override
  String get langEl => 'Bahasa Yunani';

  @override
  String get langEn => 'Bahasa Inggris';

  @override
  String get langEs419 => 'Bahasa Spanyol';

  @override
  String get langFr => 'Bahasa Prancis';

  @override
  String get langHe => 'Bahasa Ibrani';

  @override
  String get langHi => 'Bahasa Hindi';

  @override
  String get langId => 'Bahasa Indonesia';

  @override
  String get langJa => 'Bahasa Jepang';

  @override
  String get langKo => 'Bahasa Korea';

  @override
  String get langPtBR => 'Bahasa Portugis';

  @override
  String get langRu => 'Bahasa Rusia';

  @override
  String get langTr => 'Bahasa Turki';

  @override
  String get langVi => 'Bahasa Vietnam';

  @override
  String get langZhCN => 'Bahasa Mandarin';
}
