import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question.dart';

class ApiService {
  static const String baseUrl = 'https://dev.jem-formation.fr';
  static const String _baseUrlApi = '$baseUrl/fr/api/v1/quiz';

  Future<List<Question>> fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse(_baseUrlApi));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Question.fromJson(item)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des questions');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API: $e');
    }
  }
}
