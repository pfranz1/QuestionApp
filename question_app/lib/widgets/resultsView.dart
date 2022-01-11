import 'package:flutter/material.dart';
import 'package:question_app/models/models.dart';

class ResultsCard extends StatefulWidget {
  ResultsCard({Key? key, required this.results, required this.options})
      : super(key: key);

  final List<String> results;
  final List<String> options;

  @override
  State<ResultsCard> createState() => _ResultsCardState();
}

class _ResultsCardState extends State<ResultsCard> {
  late final ResultsContainer resultsContainer;

  @override
  void initState() {
    resultsContainer = ResultsContainer(widget.results, widget.options);
    super.initState();
    resultsContainer.computeResults().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final double avalaibleHeight = MediaQuery.of(context).size.height * 0.45;
    if (resultsContainer.resolutionComputed) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: avalaibleHeight,
          decoration: BoxDecoration(
            border: Border.all(width: 2.0),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Center(
              child: Text(
                  '${resultsContainer.winner} wins!\n ${resultsContainer.results}')),
        ),
      );
    } else {
      return Container(
        height: avalaibleHeight,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
  }
}
