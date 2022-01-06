import 'package:flutter/material.dart';

class ResultsCard extends StatelessWidget {
  const ResultsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double avalaibleHeight = MediaQuery.of(context).size.height * 0.45;

    return Container(
      height: avalaibleHeight,
      decoration: BoxDecoration(
        border: Border.all(width: 2.0),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Center(child: Text('Results here please!')),
    );
  }
}
