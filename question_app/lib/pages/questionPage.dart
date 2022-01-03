import '../models/models.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({Key? key}) : super(key: key);

  final Question question = const Question(
      questionText: "Who is the coolest developers in USA?",
      options: [
        "Peter",
        "Peter2",
        "Peter3",
        "Peter4",
        "Peter",
        "Peter2",
        "Peter3",
        "Peter4",
      ]);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: double.infinity,
          width: double.infinity,
          child: QuestionInterface(question: widget.question)),
    );
  }
}
