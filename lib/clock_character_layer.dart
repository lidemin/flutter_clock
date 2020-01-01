import 'dart:math';

import 'package:flutter/material.dart';

import 'baijiaxing.dart';
import 'clock_digit_layer.dart';

class ClockCharacterLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: CharactorPainter(),
        ),
      ),
    );
  }
}

class CharactorPainter extends CustomPainter {
  Size lastSize;

  var paddingHorizontal = 0.0;
  var paddingVertical = 0.0;
  var squareSize = 0;
  var digitTop = 0;
  var digitLefts = new List(kTotalDigits);
  int actualTotalWidthPixel = 0;
  int actualTotalHeightPixel = 0;

  int centerPixelDx = 0;
  int centerPixelDy = 0;

  int clockLeft = 0;
  int clockTop = 0;
  int clockRight = 0;
  int clockBottom = 0;

  TextStyle textStyle;

  TextStyle highlightedTextStyle;

  @override
  void paint(Canvas canvas, Size size) {
    print("repaint characters");
    if (lastSize != size) {
      lastSize = size;
      _reCalculate(size);
    }

    for (int i = 0; i < actualTotalWidthPixel; i++) {
      for (int j = 0; j < actualTotalHeightPixel; j++) {
        // draw background text
        _drawTextAt(canvas, i, j, textStyle);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void _reCalculate(Size size) {
    squareSize = min((size.width / kTotalWidthPixel).floor(),
        (size.height / kTotalHeightPixel).floor());

    actualTotalWidthPixel =
        ((size.width / squareSize).floor() / 2).floor() * 2 - 1;
    actualTotalHeightPixel =
        ((size.height / squareSize).floor() / 2).floor() * 2 - 1;

    centerPixelDx = (actualTotalWidthPixel / 2).floor();
    centerPixelDy = (actualTotalHeightPixel / 2).floor();

    clockLeft = centerPixelDx - (kTotalWidthPixel / 2).floor();
    clockTop = centerPixelDy - (kTotalHeightPixel / 2).floor();
    clockRight = centerPixelDx + (kTotalWidthPixel / 2).floor();
    clockBottom = centerPixelDy + (kTotalHeightPixel / 2).floor();

    digitTop = clockTop + kTotalPaddingPixel + kDigitPaddingPixel;
    for (int k = 0; k < kTotalDigits; k++) {
      digitLefts[k] = clockLeft +
          kTotalPaddingPixel +
          kDigitPaddingPixel +
          (kDigitWidthPixel + kDigitPaddingPixel) * k;
    }

    paddingHorizontal = (size.width - squareSize * actualTotalWidthPixel) / 2;
    paddingVertical = (size.height - squareSize * actualTotalHeightPixel) / 2;

    textStyle = TextStyle(
      color: Colors.green.withOpacity(0.4),
      fontSize: squareSize * 5 / 9,
      height: 1,
    );

    highlightedTextStyle = TextStyle(
      color: Colors.green.withOpacity(0.9),
      fontSize: squareSize * 5 / 9,
      fontWeight: FontWeight.w900,
      height: 1,
    );
  }

  void _drawTextAt(Canvas canvas, int i, int j, TextStyle textStyle) {
    if (i < 0 || j < 0) {
      return;
    }
    final textSpan = TextSpan(
      text: baijiaxing[
          (((actualTotalWidthPixel - i - 1) * actualTotalHeightPixel + j) %
              baijiaxing.length)],
      style: textStyle,
    );

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: squareSize.toDouble() / 2,
    );

    textPainter.paint(
      canvas,
      Offset(
        paddingHorizontal + i * squareSize + squareSize * 2 / 9,
        paddingVertical + j * squareSize + squareSize * 2 / 9,
      ),
    );
  }
}
