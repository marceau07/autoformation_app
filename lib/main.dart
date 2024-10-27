import 'package:app_links/app_links.dart';
import 'package:autoformation_app/app_router.dart';
import 'package:autoformation_app/pages/home_screen.dart';
import 'package:autoformation_app/pages/quiz_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final AppRouter appRouter = AppRouter();
  WidgetsFlutterBinding.ensureInitialized();

  // Verrouille l'application en mode portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Hive.initFlutter();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    navigatorKey: navigatorKey,
    onGenerateRoute: appRouter.generateRoute,
    initialRoute: AppRouter.homeRoute,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  late bool uuidFound = false;
  late final Widget _quiz;
  late final Widget _home = HomeScreen();
  bool hasNavigatedToQuiz = false; // Drapeau de vérification

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    _appLinks.uriLinkStream.listen((uri) {
      if (kDebugMode) {
        print('Lien détecté : $uri');
      }
      _handleDeepLink(uri);
    }, onError: (err) {
      if (kDebugMode) {
        print('Erreur lors de la gestion du lien: $err');
      }
    });
  }

  void _handleDeepLink(Uri? uri) {
    if (uri != null && !hasNavigatedToQuiz) {
      if (uri.scheme == 'paf' && uri.host == 'quiz') {
        final quizUuid =
            uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        if (quizUuid != null) {
          if (kDebugMode) {
            print('GO to $quizUuid');
          }
          setState(() {
            uuidFound = true;
            _quiz = QuizScreen(quizUuid: quizUuid);
          });
        }
      }
    } else {
      if (kDebugMode) {
        print('Lien non géré : $uri');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return !uuidFound ? _home :
      MaterialApp(
        title: 'Quiz App',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            color: Colors.blue,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(
            color: Colors.grey[900],
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),
        ),
        home: Scaffold(
          appBar: AppBar(title: const Text('Quiz App')),
          body: uuidFound
              ? _quiz
              : Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Start Quiz'),
                    ],
                  ),
                ),
        ),
      );
  }
}
