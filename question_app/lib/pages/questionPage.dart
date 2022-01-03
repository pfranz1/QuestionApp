import 'package:provider/provider.dart';
import 'package:question_app/applicationState.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({Key? key}) : super(key: key);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return Scaffold(
        body: Container(
            height: double.infinity,
            width: double.infinity,
            child: QuestionInterface(question: appState.question)),
      );
    });
  }
}
