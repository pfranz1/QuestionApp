import 'package:flutter/material.dart';

class CircleIndicatorBar extends StatelessWidget {
  final int currentSelection;
  final int numOfBalls;
  final Function callback;
  static final double _ballSize = 25;

  CircleIndicatorBar(
      {required this.currentSelection,
      required this.numOfBalls,
      required this.callback,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < numOfBalls; i++) {
      Widget next;
      final bool isSelected = i == currentSelection;
      next = InkWell(
        onTap: () => callback(i),
        child: IndicatorBall(
          ballSize: _ballSize,
          isSelected: isSelected,
        ),
      );
      children.add(next);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
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
    final color = isSelected
        ? Theme.of(context).colorScheme.onSurface.withAlpha(255)
        : Theme.of(context).colorScheme.onSurface.withAlpha(155);
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 4.0),
      child: Container(
          height: _ballSize,
          width: _ballSize,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    );
  }
}
