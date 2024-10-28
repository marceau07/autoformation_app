import 'package:flutter/material.dart';
import 'package:autoformation_app/pages/home_screen.dart';
import 'package:autoformation_app/pages/login_screen.dart';
// import 'package:autoformation_app/pages/profile_screen.dart';
import 'package:autoformation_app/pages/quiz_screen.dart';
// import 'package:autoformation_app/pages/not_found_screen.dart';

class AppRouter {
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String profileRoute = '/profile';
  static const String quizRoute = '/quiz';

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      // case profileRoute:
      //   return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case quizRoute:
        final quizUuid = settings.arguments as String?;
        if (quizUuid != null) {
          return MaterialPageRoute(builder: (_) => QuizScreen(quizUuid: quizUuid));
        }
        throw Exception("Quiz ID manquant");
        // return _errorRoute("Quiz ID manquant");
      default:
        throw Exception("Page non trouvée");
        // return _errorRoute("Page non trouvée");
    }
  }

  // Route<dynamic> _errorRoute(String message) {
  //   return MaterialPageRoute(
  //     builder: (_) => NotFoundScreen(errorMessage: message),
  //   );
  // }
}
