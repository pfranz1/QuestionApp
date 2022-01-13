import 'package:flutter/material.dart';
import 'package:question_app/models/question.dart';
import 'package:question_app/services/services.dart';

class QuestionInterface extends StatelessWidget {
  QuestionInterface({Key? key, required this.question, required this.onSubmit})
      : super(key: key) {
    questionOptionsList =
        QuestionOptionList(optionList: question?.options ?? []);
    initalOptionOrdering = List<String?>.from(question?.options ?? []);
  }

  final Question? question;
  late List<String?> initalOptionOrdering;
  late QuestionOptionList questionOptionsList;

  final void Function(String) onSubmit;

  void submitRanking() {
    List<String?> ordering = questionOptionsList.optionList;
    String rankings = '';
    for (String? element in ordering) {
      if (element == null) break;

      final int elementId = initalOptionOrdering.indexOf(element);
      rankings += "$elementId,";
    }
    onSubmit(rankings);
  }

  @override
  Widget build(BuildContext context) {
    if (question == null) {
      return const SizedBox(
        height: 100,
        width: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: QuestionHeader(questionText: question?.questionText),
          ),
          questionOptionsList,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                    onPressed: () {
                      submitRanking();
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).colorScheme.secondary),
                    child: Text(
                      'Submit',
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary),
                    )),
              ),
            ],
          )
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
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          questionText ?? 'No question avaliable.',
          style: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
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

const offsetPerOption = 4.0; //margin + border width

class _QuestionOptionListState extends State<QuestionOptionList> {
  @override
  Widget build(BuildContext context) {
    final double avalaibleHeight = MediaQuery.of(context).size.height * 0.45;
    final double avalaibleHeightPerOption =
        (avalaibleHeight - (offsetPerOption * widget.optionList.length)) /
            widget.optionList.length;

    return Container(
      height: avalaibleHeight,
      decoration: BoxDecoration(
        border: Border.all(width: 2.0),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ReorderableListView(
        buildDefaultDragHandles: true,
        header: const SizedBox(
          height: offsetPerOption,
        ),
        children: [
          for (String? option in widget.optionList)
            QuestionOptionElement(
              key: option != null ? Key(option) : UniqueKey(),
              option: option,
              height: avalaibleHeightPerOption,
            ),
        ],
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final String? item = widget.optionList.removeAt(oldIndex);
            widget.optionList.insert(newIndex, item);
          });
        },
      ),
    );
  }
}

class QuestionOptionElement extends StatelessWidget {
  QuestionOptionElement({Key? key, this.option, this.height})
      : color = ColorHasher.getColor(option ?? 'nothing').withOpacity(1.0),
        super(key: key);

  final String? option;
  final double? height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        child: ListTile(
          tileColor: color,
          title: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  option ?? '---',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
