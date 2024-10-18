
import 'package:autoformation_app/pages/QuizScreen.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

void main() {
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PAF App',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const QuizPage(),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    // Écoute les nouveaux liens quand l'application est en cours d'exécution.
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print('Erreur lors de la gestion du lien: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'paf' && uri.host == 'quiz') {
      final quizUuid = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      if (quizUuid != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(quizUuid: quizUuid),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Quiz App')),
        body: const Center(
          child: Text('Scanne un QR code pour commencer le quiz.'),
        ),
      ),
    );
  }
}