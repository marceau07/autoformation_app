import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question.dart';

class ApiService {
  static const String baseUrl = 'https://dev.jem-formation.fr';
  static const String _baseUrlApi = '$baseUrl/fr/api/v1/quiz';

  Future<List<Question>> fetchQuestions(String sUuid) async {
    print(sUuid);
    try {
      print("QUERYING API: " + _baseUrlApi + '/' + sUuid);
      final response = await http.get(Uri.parse(_baseUrlApi + '/' + sUuid));

      print("RESPONSE: " + response.statusCode.toString());
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        print(jsonData);
        jsonData.map((item) => print(item));
        return jsonData.map((item) => Question.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        // Si la réponse est une liste de JSON
        List<dynamic> jsonData = jsonDecode(response.body);

        // Assurer que la liste n'est pas vide et qu'elle contient au moins un objet
        if (jsonData.isNotEmpty && jsonData[0] is Map<String, dynamic>) {
          print("C'est pas vide !!");
          Map<String, dynamic> firstItem = jsonData[0];

          // Vérifier si le message est présent dans le premier objet de la liste
          if (firstItem.containsKey('message')) {
            print(firstItem['message']);
          } else {
            print('Aucun message d\'erreur disponible');
          }

          // Lancer une exception avec le message d'erreur
          throw Exception(
              firstItem['message'] ?? 'Erreur 404 : Ressource non trouvée');
        } else {
          throw Exception('Réponse inattendue du serveur');
        }
      } else {
        throw Exception('Erreur lors de la récupération des questions');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API: $e');
    }
  }
}
