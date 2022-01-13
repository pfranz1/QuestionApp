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
  void navigateToQuestion(
      String qId, bool? hasVoted, ApplicationState appState) {
    // Navigator.pushNamed(context, '/$qId');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => QuestionPage(
                  appState: appState,
                  qId: qId,
                  hasVoted: hasVoted,
                ),
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
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: Text("Peter's Question App"),
            titleTextStyle: Theme.of(context)
                .textTheme
                .headline3!
                .copyWith(color: Theme.of(context).colorScheme.onPrimary),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Authentication(
                    loginState: appState.loginState,
                    email: appState.email,
                    startLoginFlow: appState.startLoginFlow,
                    verifyEmail: appState.verifyEmail,
                    signInWithEmailAndPassword:
                        appState.signInWithEmailAndPassword,
                    cancelRegistration: appState.cancelRegistration,
                    registerAccount: appState.registerAccount,
                    signOut: appState.signOut),
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                  for (QuestionSelectInfoContainer myQuestion
                      in appState.myQuestions ?? [])
                    //TODO: Remove handling this old idea
                    if (myQuestion.qId != 'defaultQuestionId')
                      qSelectCard(
                        qId: myQuestion.qId,
                        qText: myQuestion.qText,
                        onSelect: () {
                          navigateToQuestion(
                              myQuestion.qId, myQuestion.hasVoted, appState);
                        },
                      )

                  // Text(myQuestion.qText)
                ],
                StyledButton(child: Icon(Icons.add), onPressed: () {}),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: Text("Peter's Question App"),
            titleTextStyle: Theme.of(context)
                .textTheme
                .headline3!
                .copyWith(color: Theme.of(context).colorScheme.onPrimary),
            centerTitle: true,
          ),
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
