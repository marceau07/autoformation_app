import 'package:autoformation_app/models/question.dart';
import 'package:autoformation_app/services/api_service.dart';
import 'package:autoformation_app/services/media_display_service.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String quizUuid;

  const QuizScreen({super.key, required this.quizUuid});

  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends State<QuizScreen> {
  late Future<List<Question>> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  final Map<int, String> _selectedAnswers = {}; // Map pour stocker les réponses sélectionnées

  @override
  void initState() {
    super.initState();
    _questions = ApiService().fetchQuestions(widget.quizUuid);
  }

  void _nextQuestion(List<Question> questions) {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showResultDialog();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _selectAnswer(String selectedOption, List<Question> questions) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = selectedOption;
    });

    // Mise à jour du score si la réponse est correcte
    if (selectedOption == questions[_currentQuestionIndex].answer) {
      _score++;
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz terminé'),
        content: Text('Ton score est de $_score'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _selectedAnswers.clear();
                _questions = ApiService().fetchQuestions(widget.quizUuid);
              });
              Navigator.pop(context);
            },
            child: const Text('Recommencer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Couleur de fond
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Hello!",
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Action pour la recherche
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Question>>(
        future: _questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune question disponible'));
          } else {
            var questions = snapshot.data!;
            var question = questions[_currentQuestionIndex];

            List<Widget> field = [];
            if ((question.type == 'unique_choice' ||
                    question.type == 'multiple_choice') &&
                question.options!.isNotEmpty) {
              List.generate(question.options!.length, (index) {
                field.add(Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ElevatedButton(
                    onPressed: () =>
                        _selectAnswer(index.toString(), questions),
                    child: Text(question.options![index]),
                  ),
                ));
              });
            } else if (question.type == 'true_false') {
              field.add(Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton(
                  onPressed: () => _selectAnswer('true', questions),
                  child: const Text('Vrai'),
                ),
              ));
              field.add(Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton(
                  onPressed: () => _selectAnswer('false', questions),
                  child: const Text('Faux'),
                ),
              ));
            } else if (question.type == 'short_answer' || question.type == 'long_answer') {
              field.add(Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                    onSubmitted: (value) => _selectAnswer(value, questions),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Entrez votre réponse',
                      hintStyle: TextStyle(color: Colors.white70),
                    )),
              ));
            } else {
              field.add(const Text('Aucune option disponible',
                  style: TextStyle(color: Colors.white)));
            }

            String themeIllustration = question.theme?.illustration ?? '';
            Color themeColor = question.theme != null
                ? Color(int.parse('0xFF${question.theme!.color.substring(1)}'))
                : Colors.grey; // Couleur par défaut si theme est null

            return Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: MediaDisplay(
                          url: ApiService.baseUrl + themeIllustration,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      question.question,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: themeColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: field,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: _currentQuestionIndex > 0
                              ? _previousQuestion
                              : null, // Désactiver si la première question
                          child: const Text('Précédent'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: _currentQuestionIndex <
                                  questions.length - 1
                              ? () => _nextQuestion(questions)
                              : null, // Désactiver si la dernière question
                          child: const Text('Suivant'),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Question ${_currentQuestionIndex + 1} / ${questions.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      )
    );
  }
}
