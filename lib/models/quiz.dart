import 'package:autoformation_app/models/theme_data.dart';
import 'package:autoformation_app/models/module.dart';

class Quiz {
  final String title;
  final String uuid;
  final Module module;
  final ThemeData theme;

  Quiz({
    required this.title,
    required this.uuid,
    required this.module,
    required this.theme,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      title: json['title'],
      uuid: json['uuid'],
      module: Module.fromJson(json['module']),
      theme: ThemeData.fromJson(json['theme']),
    );
  }
}