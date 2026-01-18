class Flashcard {
  final String id;
  final String frontText;
  final String backText;
  final String? reading;
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
    this.frontAudio,
    this.backAudio,
    this.imageUrl,
    this.priority = 5,
    this.lastSeen,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      frontText: json['frontText'] as String,
      backText: json['backText'] as String,
      reading: json['reading'] as String?,
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
}
