import 'theme_data.dart';

class Question {
  final String uuid;
  final String question;
  final List<String>? options;
  final String? answer;
  final String type;
  final ThemeData? theme;

  Question({
    required this.uuid,
    required this.question,
    this.options,
    this.answer,
    required this.type,
    this.theme,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      uuid: json['uuid'] as String,
      question: json['question'] as String,
      options: json['options'] != null && json['options'].isNotEmpty
          ? List<String>.from(json['options'])
          : null,
      answer: json['answer'] as String?,
      type: json['type'] as String,
      theme: json['theme'] != null ? ThemeData.fromJson(json['theme']) : null,
    );
  }
}


