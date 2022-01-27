import 'dart:math';

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

class _QuestionOptionListState extends State<QuestionOptionList> {
  static const _offsetPerOption = 4.0; //margin + border width

  @override
  Widget build(BuildContext context) {
    final double avalaibleHeight = MediaQuery.of(context).size.height * 0.45;
    final double avalaibleHeightPerOption =
        (avalaibleHeight - (_offsetPerOption * widget.optionList.length)) /
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
          height: _offsetPerOption,
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

//Results region
class ResultsCard extends StatefulWidget {
  ResultsCard({Key? key, required this.results, required this.question})
      : super(key: key);
  final List<String> results;
  final Question question;

  @override
  _ResultsCardState createState() => _ResultsCardState();
}

class _ResultsCardState extends State<ResultsCard> {
  late final ResultsContainer resultsContainer;
  int selectedFrame = 0;

  @override
  void initState() {
    resultsContainer =
        ResultsContainer(widget.results, widget.question.options);
    resultsContainer.addListener(() => setState(() {}));
    _computeResults();
    super.initState();
  }

  Future _computeResults() async {
    await resultsContainer.tryComputeResults();
  }

  Widget get _loadedWidget {
    assert(selectedFrame < resultsContainer.frames.length);
    final currentSnapshot = resultsContainer.frames[selectedFrame].snapshots;
    final double avaliableHeight = MediaQuery.of(context).size.height * 0.45;
    final double avaliableHeightPerElement =
        avaliableHeight / widget.question.options.length;

    final double padding = 16.0;
    final double avaliableWidth = MediaQuery.of(context).size.width;
    final Color resultCardColor = Theme.of(context).colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: [
            QuestionHeader(
              questionText: widget.question.questionText,
            ),
            const SizedBox(
              height: 15,
            ),
            //Card that the colored boxes with results sit ontop
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1.0),
                borderRadius: BorderRadius.circular(16.0),
                color: Theme.of(context).colorScheme.surface,
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color.lerp(resultCardColor, Colors.white, 0.2)!,
                      Color.lerp(resultCardColor, Colors.black, 0.2)!,
                    ]),
              ),
              child: Column(
                children: [
                  ...[
                    const SizedBox(
                      height: 16.0,
                    ),
                    for (final id in resultsContainer.finalOrdering
                        .split("")
                        .map((element) => int.parse(element)))
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 16.0, left: 16.0, right: 16.0),
                        child: SingleResultCard(
                          snapshot: currentSnapshot[id],
                          optionText: widget.question.options[id],
                          height: avaliableHeightPerElement,
                          maxWidth: avaliableWidth,
                          percent: (currentSnapshot[id].votes /
                              resultsContainer.results.length),
                          votes: currentSnapshot[id].votes.toString(),
                        ),
                      )
                  ],
                ],
              ),
            ),
            CircleIndicatorBar(currentSelection: selectedFrame)
          ],
        ),
      ),
    );
  }

  Widget get _loadingWidget {
    return Container(
      child: CircularProgressIndicator(),
    );
  }

  Widget get _loadErrorWidget {
    return Container(
      child: Text('Error computing results'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool _isError =
        resultsContainer.resolutionComputed == ComputationState.error;
    final bool _resultsLoaded =
        resultsContainer.resolutionComputed == ComputationState.done;
    if (_resultsLoaded) {
      return _loadedWidget;
    } else if (!_isError) {
      return _loadingWidget;
    } else {
      return _loadErrorWidget;
    }
  }
}

class CircleIndicatorBar extends StatelessWidget {
  final int currentSelection;
  static final double _ballSize = 25;

  CircleIndicatorBar({required this.currentSelection, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < 3; i++) {
      Widget next;
      final bool isSelected = i == currentSelection;
      next = IndicatorBall(
        ballSize: _ballSize,
        isSelected: isSelected,
      );
      children.add(next);
    }

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class IndicatorBall extends StatelessWidget {
  const IndicatorBall({
    Key? key,
    required double ballSize,
    required this.isSelected,
  })  : _ballSize = ballSize,
        super(key: key);

  final double _ballSize;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: _ballSize,
        width: _ballSize,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.amber));
  }
}

class SingleResultCard extends StatelessWidget {
  SingleResultCard({
    Key? key,
    required this.snapshot,
    required this.optionText,
    required this.height,
    required this.percent,
    required this.votes,
    required double maxWidth,
  })  : color = ColorHasher.getColor(optionText).withOpacity(1.0),
        percentText = (percent * 100).toStringAsPrecision(4) + "%",
        votingInfoWidth = maxWidth * 0.15,
        growableRectangleWidth = (maxWidth - (maxWidth * 0.15) - (27.0 * 2)) *
            percent, //The 27.0 is the padding thats defined widgets above
        super(key: key);

  final Color color;
  final String optionText;
  final String votes;
  final String percentText;

  final double height;
  final double votingInfoWidth;
  final double growableRectangleWidth;

  final double percent;

  final ElementVCSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color.lerp(Colors.black, color, 0.25),
          border: Border.all(width: 2.0)),
      child: Column(
        children: [
          TopResultBar(color: color, optionText: optionText),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 50, minWidth: 0),
                height: height,
                width: growableRectangleWidth,
                decoration: BoxDecoration(color: color),
              ),
              VotingInfo(
                  height: height,
                  votingInfoWidth: votingInfoWidth,
                  percentText: percentText,
                  votes: votes)
            ],
          ),
        ],
      ),
    );
  }
}

class TopResultBar extends StatelessWidget {
  const TopResultBar({
    Key? key,
    required this.color,
    required this.optionText,
  }) : super(key: key);

  final Color color;
  final String optionText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: color,
          border:
              Border(bottom: BorderSide(color: Colors.black54, width: 3.0))),
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              "$optionText",
              style: Theme.of(context).textTheme.headline4!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ),
      )),
    );
  }
}

class VotingInfo extends StatelessWidget {
  const VotingInfo({
    Key? key,
    required this.height,
    required this.votingInfoWidth,
    required this.percentText,
    required this.votes,
  }) : super(key: key);

  final double height;
  final double votingInfoWidth;
  final String percentText;
  final String votes;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: votingInfoWidth,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Builder(builder: (context) {
        final TextStyle textStyle =
            Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 16.0);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${percentText}",
              style: textStyle,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "${votes} Votes",
              style: textStyle,
            )
          ],
        );
      }),
    );
  }
}
