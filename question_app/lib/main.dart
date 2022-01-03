import 'package:flutter/material.dart';
import 'package:question_app/pages/questionPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Question App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QuestionPage(),
    );
  }
}
