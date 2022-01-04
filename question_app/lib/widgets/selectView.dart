import 'package:flutter/material.dart';

class qSelectCard extends StatelessWidget {
  const qSelectCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(width: 2.0)),
      ),
    );
  }
}


