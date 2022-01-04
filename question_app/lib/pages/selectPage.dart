import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:question_app/applicationState.dart';
import 'package:question_app/widgets/widgets.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({Key? key}) : super(key: key);

  @override
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
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
                const Text(
                    'You will be able to select and see youre questions'),
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
