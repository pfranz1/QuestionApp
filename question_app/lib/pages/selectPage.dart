import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:question_app/applicationState.dart';
import 'package:question_app/pages/pages.dart';
import 'package:question_app/widgets/widgets.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({Key? key}) : super(key: key);

  @override
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  void navigateToQuestion(String qId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const QuestionPage(),
            settings: RouteSettings(name: '/$qId')));
  }

  @override
  Widget build(BuildContext context) {
    // Authentication(
    //     loginState: appState.loginState,
    //     email: appState.email,
    //     startLoginFlow: appState.startLoginFlow,
    //     verifyEmail: appState.verifyEmail,
    //     signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
    //     cancelRegistration: appState.cancelRegistration,
    //     registerAccount: appState.registerAccount,
    //     signOut: appState.signOut);
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      if (appState.loginState == ApplicationLoginState.loggedIn) {
        return Scaffold(
          body: Center(
            child: Column(
              children: [
                ...[
                  for (QuestionSelectInfoContainer myQuestion
                      in appState.myQuestions ?? [])
                    //TODO: Remove handling this old idea
                    if (myQuestion.qId != 'defaultQuestionId')
                      qSelectCard(
                        qId: myQuestion.qId,
                        qText: myQuestion.qText,
                        onSelect: (qId) {
                          appState.loadQuestion(qId);
                          navigateToQuestion(qId);
                        },
                      )

                  // Text(myQuestion.qText)
                ],
                StyledButton(child: Icon(Icons.add), onPressed: () {}),
                Authentication(
                    loginState: appState.loginState,
                    email: appState.email,
                    startLoginFlow: appState.startLoginFlow,
                    verifyEmail: appState.verifyEmail,
                    signInWithEmailAndPassword:
                        appState.signInWithEmailAndPassword,
                    cancelRegistration: appState.cancelRegistration,
                    registerAccount: appState.registerAccount,
                    signOut: appState.signOut),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Center(
            child: Column(
              children: [
                Authentication(
                    loginState: appState.loginState,
                    email: appState.email,
                    startLoginFlow: appState.startLoginFlow,
                    verifyEmail: appState.verifyEmail,
                    signInWithEmailAndPassword:
                        appState.signInWithEmailAndPassword,
                    cancelRegistration: appState.cancelRegistration,
                    registerAccount: appState.registerAccount,
                    signOut: appState.signOut),
              ],
            ),
          ),
        );
      }
    });
  }
}
