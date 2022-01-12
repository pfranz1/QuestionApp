import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:question_app/applicationState.dart';
import 'package:question_app/pages/pages.dart';
import 'package:question_app/widgets/widgets.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({Key? key, required this.pageName}) : super(key: key);
  final String pageName;
  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) {
        //if i am already logged in
        if (appState.loginState == ApplicationLoginState.loggedIn) {
          return QuestionPage(
              appState: appState, qId: widget.pageName.substring(1));
        }
        return Scaffold(
            body: Column(
          children: [
            CircularProgressIndicator(),
            Text(widget.pageName),
          ],
        ));
      },
    );
  }
}
