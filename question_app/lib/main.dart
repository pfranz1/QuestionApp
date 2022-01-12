import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:question_app/applicationState.dart';
import 'package:question_app/pages/questionPage.dart';
import 'package:question_app/services/routeGenerator.dart';
import 'pages/pages.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: (context, _) => MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Question App',
      initialRoute: '/',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.light(background: Colors.blueGrey[200]!)),
      // home: const SelectPage(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
