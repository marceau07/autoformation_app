class Question {
  final String uuid;
  final String question;
  final List<String> options;
  final String answer;
  final String type;
  final String themeName;
  final String themeColor;
  final String themeIllustration;

  Question({
    required this.uuid,
    required this.question,
    required this.options,
    required this.answer,
    required this.type,
    required this.themeName,
    required this.themeColor,
    required this.themeIllustration,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      uuid: json['uuid'],
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
      type: json['type'],
      themeName: json['theme']['name'],
      themeColor: json['theme']['color'],
      themeIllustration: json['theme']['illustration'],
    );
  }
}