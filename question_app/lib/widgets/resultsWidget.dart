import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:question_app/models/models.dart';
import 'package:question_app/services/services.dart';

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
    resultsContainer.addListener(() => setState(() {}));
    _computeResults();
    super.initState();
  }

  Future _computeResults() async {
    await resultsContainer.tryComputeResults();
  }

  @override
  Widget build(BuildContext context) {
    final double avalaibleHeight = MediaQuery.of(context).size.height * 0.45;
    if (resultsContainer.resolutionComputed == ComputationState.done) {
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
    } else if (resultsContainer.resolutionComputed ==
        ComputationState.loading) {
      return Container(
        height: avalaibleHeight,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Container(
        height: avalaibleHeight,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: const Center(child: Text('Error :(')),
      );
    }
  }
}
