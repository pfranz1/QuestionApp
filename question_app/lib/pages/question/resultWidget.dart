import 'package:flutter/material.dart';
import 'package:question_app/models/question.dart';
import 'package:question_app/pages/pages.dart';
import 'package:question_app/pages/question/ballRowIndicator.dart';
import 'package:question_app/services/services.dart';

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

  void _setSelectedFrame(int newSelectedFrame) {
    if (newSelectedFrame != selectedFrame) {
      setState(() {
        selectedFrame = newSelectedFrame;
      });
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            ...[
              QuestionHeader(
                questionText: widget.question.questionText,
              ),
              //Eyeballed this, just to make top look more balanced with bottom
              const SizedBox(
                height: 9,
              ),
              for (final id in resultsContainer.finalOrdering
                  .split("")
                  .map((element) => int.parse(element)))
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                  ),
                  child: SingleResultCard(
                    snapshot: currentSnapshot[id],
                    optionText: widget.question.options[id],
                    height: avaliableHeightPerElement,
                    maxWidth: avaliableWidth,
                    percent: (currentSnapshot[id].votes /
                        resultsContainer.results.length),
                    votes: currentSnapshot[id].votes.toString(),
                  ),
                ),
              const SizedBox(
                height: 4,
              ),
              CircleIndicatorBar(
                currentSelection: selectedFrame,
                numOfBalls: resultsContainer.frames.length,
                callback: _setSelectedFrame,
              ),
            ],
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
          SingleResultHeader(color: color, optionText: optionText),
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

class SingleResultHeader extends StatelessWidget {
  const SingleResultHeader({
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
