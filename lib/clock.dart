import 'package:clock/clock_character_layer.dart';
import 'package:clock/clock_digit_layer.dart';
import 'package:flutter/material.dart';

import 'clock_animation_layer.dart';

class Clock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClockCharacterLayer(),
        ClockAnimationLayer(),
        ClockDigitLayer(),
      ],
    );
  }
}
