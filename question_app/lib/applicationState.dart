import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:question_app/firebase_options.dart';
import 'package:question_app/models/models.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _questionSubscription = FirebaseFirestore.instance
        .collection('questions')
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      _question = Question(
        questionText: snapshot.docs.first.data()['questionText'] as String,
        options: List<String>.from(
            snapshot.docs.first.data()['options'] as List<dynamic>),
      );

      notifyListeners();
    });

    FirebaseFirestore.instance
        .collection('questions')
        .limit(1)
        .get()
        .then((value) => _docId = value.docs.first.reference.id);
  }

  StreamSubscription<QuerySnapshot>? _questionSubscription;
  late String _docId;
  Question? _question;
  Question? get question => _question;

  Future<DocumentReference> addResponse(String response) {
    return FirebaseFirestore.instance
        .collection('questions')
        .doc(_docId)
        .collection('responses')
        .add(<String, dynamic>{'response': response});
  }

  @override
  void dispose() {
    _questionSubscription?.cancel();
    super.dispose();
  }
}
