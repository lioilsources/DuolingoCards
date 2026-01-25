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
  final String frontText;
  final String backText;
  final String? reading;
  final CardMedia? media;
  final String? mediaStatus;

  // Legacy fields for backwards compatibility
  final String? frontAudio;
  final String? backAudio;
  final String? imageUrl;

  int priority;
  DateTime? lastSeen;

  Flashcard({
    required this.id,
    required this.frontText,
    required this.backText,
    this.reading,
    this.media,
    this.mediaStatus,
    this.frontAudio,
    this.backAudio,
    this.imageUrl,
    this.priority = 5,
    this.lastSeen,
  });

  // Helper getters that check both new and legacy fields
  String? get audioFrontUrl => media?.audioFront ?? frontAudio;
  String? get audioBackUrl => media?.audioBack ?? backAudio;
  String? get imageUrlResolved => media?.image ?? imageUrl;

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      frontText: json['frontText'] as String,
      backText: json['backText'] as String,
      reading: json['reading'] as String?,
      media: json['media'] != null
          ? CardMedia.fromJson(json['media'] as Map<String, dynamic>)
          : null,
      mediaStatus: json['mediaStatus'] as String?,
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
      'frontText': frontText,
      'backText': backText,
      'reading': reading,
      'media': media?.toJson(),
      'mediaStatus': mediaStatus,
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
    String? frontText,
    String? backText,
    String? reading,
    CardMedia? media,
    String? mediaStatus,
    String? frontAudio,
    String? backAudio,
    String? imageUrl,
    int? priority,
    DateTime? lastSeen,
  }) {
    return Flashcard(
      id: id ?? this.id,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      reading: reading ?? this.reading,
      media: media ?? this.media,
      mediaStatus: mediaStatus ?? this.mediaStatus,
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
