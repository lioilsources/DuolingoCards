enum CardType { basic, quiz }

class QuizField {
  final String label;
  final String value;

  QuizField({required this.label, required this.value});

  factory QuizField.fromJson(Map<String, dynamic> json) {
    return QuizField(
      label: json['label'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}

class QuizData {
  final String category;
  final String title;
  final String? subtitle;
  final List<QuizField> fields;
  final String? wikidataId;

  QuizData({
    required this.category,
    required this.title,
    this.subtitle,
    this.fields = const [],
    this.wikidataId,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      category: json['category'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      fields: (json['fields'] as List<dynamic>?)
              ?.map((f) => QuizField.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      wikidataId: json['wikidataId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'title': title,
        'subtitle': subtitle,
        'fields': fields.map((f) => f.toJson()).toList(),
        'wikidataId': wikidataId,
      };
}

class CardMedia {
  final String? image;
  final String? audioFront;
  final String? audioBack;
  final String? video;

  CardMedia({
    this.image,
    this.audioFront,
    this.audioBack,
    this.video,
  });

  factory CardMedia.fromJson(Map<String, dynamic> json) {
    return CardMedia(
      image: json['image'] as String?,
      audioFront: json['audioFront'] as String?,
      audioBack: json['audioBack'] as String?,
      video: json['video'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'audioFront': audioFront,
      'audioBack': audioBack,
      'video': video,
    };
  }

  CardMedia copyWith({
    String? image,
    String? audioFront,
    String? audioBack,
    String? video,
  }) {
    return CardMedia(
      image: image ?? this.image,
      audioFront: audioFront ?? this.audioFront,
      audioBack: audioBack ?? this.audioBack,
      video: video ?? this.video,
    );
  }

  CardMedia withResolvedUrls(String baseUrl) {
    String? resolveUrl(String? path) {
      if (path == null || path.isEmpty) return path;
      if (path.startsWith('http') || path.startsWith('/') || path.startsWith('assets/')) {
        return path;
      }
      return '$baseUrl/$path';
    }

    return CardMedia(
      image: resolveUrl(image),
      audioFront: resolveUrl(audioFront),
      audioBack: resolveUrl(audioBack),
      video: resolveUrl(video),
    );
  }
}

class Flashcard {
  final String id;
  final CardType type;
  final String frontText;
  final String backText;
  final String? reading;
  final CardMedia? media;
  final String? mediaStatus;
  final QuizData? quizData;

  // Legacy fields for backwards compatibility
  final String? frontAudio;
  final String? backAudio;
  final String? imageUrl;

  int priority;
  DateTime? lastSeen;

  Flashcard({
    required this.id,
    this.type = CardType.basic,
    required this.frontText,
    required this.backText,
    this.reading,
    this.media,
    this.mediaStatus,
    this.quizData,
    this.frontAudio,
    this.backAudio,
    this.imageUrl,
    this.priority = 5,
    this.lastSeen,
  });

  bool get isQuiz => type == CardType.quiz;

  // Helper getters that check both new and legacy fields
  String? get audioFrontUrl => media?.audioFront ?? frontAudio;
  String? get audioBackUrl => media?.audioBack ?? backAudio;
  String? get imageUrlResolved => media?.image ?? imageUrl;

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = typeStr == 'quiz' ? CardType.quiz : CardType.basic;

    return Flashcard(
      id: json['id'] as String,
      type: type,
      frontText: json['frontText'] as String? ?? '',
      backText: json['backText'] as String? ?? '',
      reading: json['reading'] as String?,
      media: json['media'] != null
          ? CardMedia.fromJson(json['media'] as Map<String, dynamic>)
          : null,
      mediaStatus: json['mediaStatus'] as String?,
      quizData: json['quizData'] != null
          ? QuizData.fromJson(json['quizData'] as Map<String, dynamic>)
          : null,
      frontAudio: json['frontAudio'] as String?,
      backAudio: json['backAudio'] as String?,
      imageUrl: json['imageUrl'] as String?,
      priority: json['priority'] as int? ?? 5,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == CardType.quiz ? 'quiz' : 'basic',
      'frontText': frontText,
      'backText': backText,
      'reading': reading,
      'media': media?.toJson(),
      'mediaStatus': mediaStatus,
      'quizData': quizData?.toJson(),
      'frontAudio': frontAudio,
      'backAudio': backAudio,
      'imageUrl': imageUrl,
      'priority': priority,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  void increasePriority() {
    if (priority < 10) priority++;
    lastSeen = DateTime.now();
  }

  void decreasePriority() {
    if (priority > 1) priority--;
    lastSeen = DateTime.now();
  }

  Flashcard copyWith({
    String? id,
    CardType? type,
    String? frontText,
    String? backText,
    String? reading,
    CardMedia? media,
    String? mediaStatus,
    QuizData? quizData,
    String? frontAudio,
    String? backAudio,
    String? imageUrl,
    int? priority,
    DateTime? lastSeen,
  }) {
    return Flashcard(
      id: id ?? this.id,
      type: type ?? this.type,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      reading: reading ?? this.reading,
      media: media ?? this.media,
      mediaStatus: mediaStatus ?? this.mediaStatus,
      quizData: quizData ?? this.quizData,
      frontAudio: frontAudio ?? this.frontAudio,
      backAudio: backAudio ?? this.backAudio,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Flashcard withResolvedMediaUrls(String baseUrl) {
    if (media == null) return this;
    return copyWith(media: media!.withResolvedUrls(baseUrl));
  }
}
