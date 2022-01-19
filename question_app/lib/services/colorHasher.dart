import 'package:flutter/material.dart';

class ColorHasher {
  static const int centerLine = 155;
  static Color getColor(String input) {
    input.hashCode;
    final increment = (input.hashCode % 50);
    int plusOrMinus = input.hashCode.isEven ? -1 : 1;

    return Color.fromRGBO(
        centerLine - increment * plusOrMinus * 4,
        centerLine + increment * plusOrMinus * 7,
        centerLine - increment * plusOrMinus * 9,
        0);
  }
}
