import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:question_app/firebase_options.dart';
import 'package:question_app/models/models.dart';
import 'widgets/widgets.dart';
import 'models/models.dart';

class QuestionSelectInfoContainer {
  final String qText;
  final String qId;

  QuestionSelectInfoContainer({required this.qId, required this.qText});

  @override
  String toString() {
    return '{$qId,$qText}';
  }
}

enum QuestionLoadState { loading, done, error }

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _questionLoadState = QuestionLoadState.loading;

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;

        _myQuestionsSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('addedQuestions')
            .snapshots()
            .listen((snapshot) {
          _myQuestions = [];
          for (QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs) {
            _myQuestions!.add(QuestionSelectInfoContainer(
                qId: doc.data()['qId'] as String,
                qText: doc.data()['qText'] as String));
          }
          notifyListeners();
        });
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _questionLoadState = QuestionLoadState.loading;
        _question = null;
        _myQuestions = null;
        _myQuestionsSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  StreamSubscription<QuerySnapshot>? _myQuestionsSubscription;
  List<QuestionSelectInfoContainer>? _myQuestions;
  List<QuestionSelectInfoContainer>? get myQuestions => _myQuestions;

  QuestionLoadState? _questionLoadState;
  QuestionLoadState? get questionLoadState => _questionLoadState;

  Question? _question;
  Question? get question => _question;

  String? _questionId;

  // Future<DocumentReference> makeQuestion(Question question,
  //     {String? questionID}) {
  //   //update question inside of myQuestions collection
  //   //update question inside of questionCollection
  // }

  // Future<DocumentReference> updateQuestion() {}

  //region Question region
  void loadQuestion(String qId) async {
    _question = null;
    _questionId = qId;
    _questionLoadState = QuestionLoadState.loading;
    notifyListeners();

    final ref = FirebaseFirestore.instance.collection('questions').doc(qId);
    try {
      final snapshot = await ref.get();
      print(snapshot.data());
      _question = Question(
        questionText: snapshot.data()!['questionText'] as String,
        options:
            List<String>.from(snapshot.data()!['options'] as List<dynamic>),
      );
      // if (Random.secure().nextInt(100) > 50) throw ('Random eroror lol');
      _questionLoadState = QuestionLoadState.done;
    } catch (e) {
      print(e);
      _question = null;
      _questionLoadState = QuestionLoadState.error;
    } finally {
      notifyListeners();
    }
  }

  void reload() {
    if (_questionLoadState == QuestionLoadState.error) {
      loadQuestion(_questionId!);
    } else {
      throw ('Reload was called while not in error state');
    }
  }

  Future<void> addResponse(String response) {
    return FirebaseFirestore.instance
        .collection('questions')
        .doc(_questionId)
        .collection('responses')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(<String, dynamic>{'response': response});
  }

  //endregion

  //#region Log-on region
  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> verifyEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> registerAccount(
      String email,
      String displayName,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);

      final CollectionReference usersRef =
          FirebaseFirestore.instance.collection('/users');
      Map<String, dynamic> userData = {
        'displayName': displayName,
        'email': credential.user!.email,
      };

      await usersRef.doc(credential.user!.uid).set(userData);
      Map<String, dynamic> questionData = {
        'qId': 'defaultQuestionId',
        'isOwner': false,
        'qText': 'defaultQuestion',
      };
      await usersRef
          .doc(credential.user!.uid)
          .collection('addedQuestions')
          .add(questionData);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
  //#endregion

  @override
  void dispose() {
    super.dispose();
  }
}
