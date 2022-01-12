import 'package:flutter/material.dart';
import 'package:question_app/pages/pages.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    if (settings.name == '/') {
      return MaterialPageRoute(
          builder: (context) => const SelectPage(),
          settings: RouteSettings(name: '/'));
    } else {
      try {
        return MaterialPageRoute(
          builder: (context) => AddQuestionPage(
            pageName: settings.name!,
          ),
          settings: RouteSettings(name: settings.name),
        );
      } catch (e) {
        print(e);
        return _errorRoute();
      }
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return const Scaffold(
        body: Center(
          child: Text('Page Not Found'),
        ),
      );
    });
  }
}
