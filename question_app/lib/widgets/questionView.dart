import 'package:flutter/material.dart';
import 'package:question_app/models/question.dart';

class QuestionInterface extends StatelessWidget {
  const QuestionInterface({Key? key, required this.question}) : super(key: key);

  final Question? question;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: QuestionHeader(questionText: question?.questionText),
          ),
          QuestionOptionList(optionList: question?.options ?? []),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                    onPressed: () {},
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
      : super(key: key) {
    color = stringToColor(option ?? 'nothing');
  }

  final String? option;
  final double? height;
  late final Color color;

  Color stringToColor(String string) {
    int randomishValue1 = string.hashCode;
    int randomishValue2 = string.length * 13;
    int randomishValue3 = string[0].hashCode * 7;
    return Color.fromARGB(255, (randomishValue1 - randomishValue2 * 4) % 225,
        (randomishValue1 + randomishValue3 * 15) % 225, randomishValue1 % 225);
  }

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
