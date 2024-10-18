import 'package:autoformation_app/models/question.dart';
import 'package:autoformation_app/services/api_service.dart';
import 'package:autoformation_app/services/media_display_service.dart';
import 'package:flutter/material.dart';

// class QuizScreen extends StatelessWidget {
//   final String quizUuid;

//   const QuizScreen({Key? key, required this.quizUuid}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Quiz $quizUuid')),
//       body: Center(
//         child: Text('Bienvenue au quiz avec l\'UUID: $quizUuid'),
//       ),
//     );
//   }
// }

class QuizScreen extends StatefulWidget {
  final String quizUuid;

  const QuizScreen({super.key, required this.quizUuid});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizScreen> {
  late Future<List<Question>> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _questions = ApiService().fetchQuestions(widget.quizUuid);
  }

  void _nextQuestion(String selectedOption, List<Question> questions) {
    if (selectedOption == questions[_currentQuestionIndex].answer) {
      _score++;
    }

    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showResultDialog();
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
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _questions = ApiService().fetchQuestions(widget.quizUuid);
              });
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
      appBar: AppBar(
        title: const Text('Quiz App'),
      ),
      backgroundColor: Color(int.parse('0xFF181818')),
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
                    onPressed: () => _nextQuestion(index.toString(), questions),
                    child: Text(question.options![index]!),
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
                  onPressed: () => _nextQuestion('true', questions),
                  child: const Text('Vrai'),
                ),
              ));
              field.add(Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton(
                  onPressed: () => _nextQuestion('false', questions),
                  child: const Text('Faux'),
                ),
              ));
            } else if (question.type == 'short_answer') {
              field.add(Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                    onSubmitted: (value) => _nextQuestion(value, questions),
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
            return Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  // First Expanded: Displays the illustration.
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: MediaDisplay(
                            url:
                                ApiService.baseUrl + question.themeIllustration,
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      question.question,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Second Expanded: Displays the question and options with rounded top corners.
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: Color(int.parse(
                            '0xFF${question.themeColor.substring(1)}')), // Adjust this color if needed
                        // decoration: BoxDecoration(
                        //   gradient: LinearGradient(
                        //     colors: [
                        //       Color(int.parse('0xFF${question.themeColor.substring(1)}')),
                        //       Colors.white
                        //     ], // Les couleurs du dégradé.
                        //     stops: [0.70, 1.0], // Les positions des couleurs.
                        //     begin: Alignment.bottomCenter, // Début du dégradé.
                        //     end: Alignment.topCenter, // Fin du dégradé.
                        //   ),
                        // ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: field,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Padding(
            //           padding: const EdgeInsets.all(16.0),
            //           child: Text(
            //             question.question,
            //             style: const TextStyle(fontSize: 18),
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //         ...List.generate(question.options.length, (index) {
            //           return Padding(
            //             padding: const EdgeInsets.symmetric(
            //                 horizontal: 16.0, vertical: 8.0),
            //             child: ElevatedButton(
            //               onPressed: () =>
            //                   _nextQuestion(index.toString(), questions),
            //               child: Text(question.options[index]),
            //             ),
            //           );
            //         }),
            //       ],
            //     ),
            //   ],
            // ));
          }
        },
      ),
    );
  }
}