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
  final bool hasVoted;

  QuestionSelectInfoContainer(
      {required this.qId, required this.qText, required this.hasVoted});

  @override
  String toString() {
    return '{$qId,$qText}';
  }
}

enum QuestionLoadState { loading, done, error }
enum ResultLoadState { loading, done, error }

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
                qText: doc.data()['qText'] as String,
                hasVoted: doc.data()['hasVoted'] as bool));
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

  List<String>? _results;
  List<String>? get results => _results;

  ResultLoadState? _resultLoadState;
  ResultLoadState? get resultLoadState => _resultLoadState;

  bool _hasVoted = false;
  bool get hasVoted => _hasVoted;

  String? _questionId;

  // Future<DocumentReference> makeQuestion(Question question,
  //     {String? questionID}) {
  //   //update question inside of myQuestions collection
  //   //update question inside of questionCollection
  // }

  // Future<DocumentReference> updateQuestion() {}

  //region Question region
  void loadQuestion(String qId, bool? hasVoted) async {
    _question = null;
    _questionId = qId;
    //If the person has voted i need to load the results along with the question
    if (hasVoted == null) {
      _hasVoted = await checkIfResponded();
    } else {
      _hasVoted = hasVoted;
    }

    if (_hasVoted) {
      getResponses();
    }
    _questionLoadState = QuestionLoadState.loading;
    // notifyListeners();

    final ref = FirebaseFirestore.instance.collection('questions').doc(qId);
    try {
      final snapshot = await ref.get();
      // print(snapshot.data());
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
      loadQuestion(_questionId!, _hasVoted);
    } else {
      throw ('Reload was called while not in error state');
    }
  }

  Future<bool> checkIfResponded() async {
    final docIdRef = FirebaseFirestore.instance
        .collection("questions")
        .doc(_questionId)
        .collection('responses')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    return docIdRef.then((value) => value.exists);
  }

  Future<void> getResponses() async {
    _resultLoadState = ResultLoadState.loading;
    _results = null;

    try {
      final responses = FirebaseFirestore.instance
          .collection('questions')
          .doc(_questionId)
          .collection('responses')
          .get();
      return responses.then((value) {
        final List<String> output = [];
        for (final element in value.docs) {
          output.add(element.data()['response']);
        }
        _results = output;
        _resultLoadState = ResultLoadState.done;
      });
    } catch (e) {
      print(e);
      _resultLoadState = ResultLoadState.error;
      _results = null;
    } finally {
      Future.delayed(Duration(seconds: 1)).then((value) => notifyListeners());
    }
  }

  Future<void> addResponse(String response) async {
    _hasVoted = true;
    //I want to add this new question to my added questions

    Map<String, dynamic> hasVotedData = {
      'hasVoted': true,
      'isOwner': false,
      'qId': _questionId,
      'qText': _question!.questionText
    };
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('addedQuestions')
        .doc(_questionId)
        .set(hasVotedData);

    getResponses();

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
