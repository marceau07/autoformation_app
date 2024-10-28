import 'package:autoformation_app/models/quiz.dart';
import 'package:autoformation_app/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question.dart';

class ApiService {
  static const String baseUrl = 'https://dev.jem-formation.fr';
  static const String _baseUrlApi = '$baseUrl/fr/api/v1/quiz';
  static const String _baseUrlUpdateApi = '$baseUrl/fr/api/v1/send/quiz';
  static const String _login_url = '$baseUrl/fr/api/v1/login';

  final _storage = const FlutterSecureStorage();

  Future<String> fetchModuleTitle(String quizUuid) async {
    final response = await http.get(Uri.parse('$_baseUrlApi/$quizUuid'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['title']; // Assure-toi que l'API renvoie un champ 'title'
    } else {
      throw Exception('Erreur lors de la récupération du titre du module');
    }
  }

  Future<List<Question>> fetchQuestions(String sUuid) async {
    print("UUID demandé: $sUuid");
    try {
      final fullUrl = '$_baseUrlApi/$sUuid/rows';
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

  Future<void> sendResult(
      String userUuid, String quizUuid, Map<int, String> questions) async {
    final Map<String, String> questionsStringMap =
        questions.map((key, value) => MapEntry(key.toString(), value));

    // Préparation des données sous forme de JSON
    final Map<String, dynamic> requestData = {
      'userUuid': userUuid,
      'quizUuid': quizUuid,
      'questions': questionsStringMap,
    };

    print('Envoi des données: $requestData');

    try {
      // Envoi de la requête POST
      final response = await http.post(
        Uri.parse(_baseUrlUpdateApi),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );
      print('Réponse: $response');

      // Traitement de la réponse
      if (response.statusCode == 200) {
        // Si l'API retourne une réponse 200 (succès)
        print('Mise à jour réussie : ${response.body}');
      } else {
        // Si l'API retourne une autre réponse, on peut afficher un message d'erreur
        print('Échec de la mise à jour : ${response.statusCode}');
        print('Message : ${response.body}');
      }
    } catch (error) {
      print('Erreur : $error');
    }
  }

  Future<void> storeUser(dynamic user) async {
    await _storage.write(key: 'userUuid', value: user['uuid']);
    await _storage.write(key: 'username', value: user['username']);
  }

  Future<String> getUserUuid() async {
    return (await _storage.read(key: 'userUuid')) ?? '';
  }

  Future<String> getUsername() async {
    return (await _storage.read(key: 'username')) ?? '';
  }
  
  void login(TextEditingController username, TextEditingController password, bool isChecked, Box<dynamic> box1, navigatorKey, context) async {
    // Création des données du corps de la requête
    Map<String, String> body = {
      'username': username.text,
      'password': password.text,
    };

    try {
      // Envoi de la requête POST
      final response = await http.post(
        Uri.parse(_login_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // Vérification de la réponse
      if (response.statusCode == 200) {

        // Décodage de la réponse JSON
        var data = jsonDecode(response.body);

        // Stockage de l'UUID de l'utilisateur
        await storeUser(data);
        print("UUID de l'utilisateur : ${data['uuid']}");
        print("Username de l'utilisateur : ${data['username']}");
        print("UUID de l'utilisateur stocké : ${await getUserUuid()}");
        print("Username de l'utilisateur stocké : ${await getUsername()}");
        // Vérification du succès de la connexion et stockage du token
        if (data['success'] == true) {
          // Si "Remember Me" est coché, sauvegarder username et token
          if (isChecked) {
            box1.put('username', username.text);
            box1.put(
                'token',
                data[
                    'token']); // Enregistre le token pour une session persistante
          }
          // Naviguer vers l'écran principal après la connexion réussie
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Gestion des erreurs de connexion
          _showErrorDialog("Erreur de connexion", data['message'], navigatorKey);
        }
      } else {
        _showErrorDialog("Erreur", "Impossible de se connecter.", navigatorKey);
      }
    } catch (e) {
      _showErrorDialog("Erreur", "Une erreur s'est produite : $e", navigatorKey);
    }
  }

  // Fonction pour afficher un message d'erreur dans une boîte de dialogue
  void _showErrorDialog(String title, String message, navigatorKey) {
    navigatorKey.currentState?.context != null
        ? showDialog(
            context: navigatorKey.currentState!.context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          )
        : null;
  }
}
