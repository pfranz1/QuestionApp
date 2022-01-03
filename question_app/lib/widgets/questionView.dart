import 'package:flutter/material.dart';
import 'package:question_app/models/question.dart';

class QuestionInterface extends StatelessWidget {
  const QuestionInterface({Key? key, required this.question}) : super(key: key);

  final Question question;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      child: Column(
        children: [
          QuestionHeader(questionText: question.questionText),
          QuestionOptionList(optionList: question.options),
        ],
      ),
    );
  }
}

class QuestionHeader extends StatelessWidget {
  const QuestionHeader({Key? key, String? this.questionText}) : super(key: key);

  final String? questionText;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        questionText ?? 'No question avaliable.',
        style: Theme.of(context).textTheme.headline3,
      ),
    );
  }
}

class QuestionOptionList extends StatefulWidget {
  const QuestionOptionList({Key? key, required this.optionList})
      : super(key: key);

  final List<String?> optionList;

  @override
  _QuestionOptionListState createState() => _QuestionOptionListState();
}

class _QuestionOptionListState extends State<QuestionOptionList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2.0),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return QuestionOptionElement(
              option: widget.optionList.elementAt(index),
            );
          },
          shrinkWrap: true,
          itemCount: widget.optionList.length,
        ),
      ),
    );
  }
}

class QuestionOptionElement extends StatelessWidget {
  const QuestionOptionElement({Key? key, this.option}) : super(key: key);

  final String? option;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Text(
            this.option ?? '---',
            style: Theme.of(context).textTheme.headline5,
          )),
        ),
      ),
    );
  }
}
