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
  }

  StreamSubscription<QuerySnapshot>? _questionSubscription;
  Question? _question;
  Question? get question => _question;

  @override
  void dispose() {
    super.dispose();
  }
}
