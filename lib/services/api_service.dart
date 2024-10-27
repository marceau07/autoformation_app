import 'package:autoformation_app/models/quiz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question.dart';

class ApiService {
  static const String baseUrl = 'https://dev.jem-formation.fr';
  static const String _baseUrlApi = '$baseUrl/fr/api/v1/quiz';

  Future<List<Question>> fetchQuestions(String sUuid) async {
    print("UUID demandé: $sUuid");
    try {
      final fullUrl = '$_baseUrlApi/$sUuid';
      print("Requête envoyée à l'API: $fullUrl");
      
      final response = await http.get(Uri.parse(fullUrl));
      
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        // Debugging: print each item individually to track structure issues
        jsonData.forEach((item) {
          print("Item JSON brut: $item");
        });

        // Transformation des données en objets de type Question
        return jsonData.map((item) {
          try {
            return Question.fromJson(item);
          } catch (e) {
            print("Erreur lors de la conversion de l'item: $item, Erreur: $e");
            throw Exception('Format de données inattendu reçu.');
          }
        }).toList();
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
      print("Erreur de connexion ou de traitement des données de l'API: $e");
      throw Exception('Erreur de connexion à l\'API: $e');
    }
  }

  Future<List<Quiz>> fetchQuizzes() async {
    print("Requête envoyée à l'API: $_baseUrlApi");
    final response = await http.get(Uri.parse(_baseUrlApi));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      // Debugging: print each item individually to track structure issues
      jsonResponse.forEach((item) {
        print("Item JSON brut: $item");
      });
      return jsonResponse.map((data) => Quiz.fromJson(data)).toList();
    } else {
      throw Exception('Erreur lors du chargement des quiz');
    }
  }
}
