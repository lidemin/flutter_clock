import 'dart:math';

import 'package:clock/baijiaxing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'digit_path_calculate.dart';

class Clock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomPaint(
        size: Size.infinite,
        painter: ClockPainter(),
      ),
    );
  }
}

const int kTotalDigits = 4;

const int kDigitWidthPixel = 5;
const int kDigitHeightPixel = 9;
const int kDigitPaddingPixel = 1;
const int kTotalPaddingPixel = 5;

const int kDigitalClockWidthPixel =
    kDigitWidthPixel * kTotalDigits + kDigitPaddingPixel * (kTotalDigits + 1);
const int kDigitalClockHeightPixel = kDigitHeightPixel + kDigitPaddingPixel * 2;
const int kTotalWidthPixel = kDigitalClockWidthPixel + kTotalPaddingPixel * 2;
const int kTotalHeightPixel = kDigitalClockHeightPixel + kTotalPaddingPixel * 2;

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

Size lastSize;

final circlePaint = Paint()..color = Colors.red.withOpacity(0.05);
final clockPaint = Paint()..color = Colors.green.withOpacity(0.05);
final centerPaint = Paint()..color = Colors.blue.withOpacity(0.8);
final digitPaint = Paint()..color = Colors.green.withOpacity(0.4);

TextStyle textStyle;
TextStyle highlightedTextStyle;

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (lastSize != size) {
      lastSize = size;
      _reCalculate(size);
    }

    for (int i = 0; i < actualTotalWidthPixel; i++) {
      for (int j = 0; j < actualTotalHeightPixel; j++) {
        // draw circles as guideline
        if (i == centerPixelDx && j == centerPixelDy) {
          // _drawCircleAt(canvas, i, j, centerPaint);
        } else if (i >= clockLeft &&
            i <= clockRight &&
            j >= clockTop &&
            j <= clockBottom) {
          // _drawCircleAt(canvas, i, j, clockPaint);
        } else {
          // _drawCircleAt(canvas, i, j, circlePaint);
        }

        // draw background text
        // _drawTextAt(i, j, textStyle, canvas);
      }
    }

    _drawDigits(
        canvas, digitPaint, intl.DateFormat("HHmm").format(DateTime.now()));
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
      color: Colors.green.withOpacity(0.5),
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

  void _drawTextAt(int i, int j, TextStyle textStyle, Canvas canvas) {
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

  void _drawCircleAt(Canvas canvas, int left, int top, Paint circlePaint) {
    canvas.drawCircle(
      Offset(
        paddingHorizontal + left * squareSize + squareSize / 2,
        paddingVertical + top * squareSize + squareSize / 2,
      ),
      squareSize * 2 / 5,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  _drawDigits(Canvas canvas, Paint paint, String digits) {
    for (int i = 0; i < kTotalDigits; i++) {
      _drawDigit(canvas, digitLefts[i], digitTop, paint, int.parse(digits[i]));
    }
  }

  _drawDigit(Canvas canvas, int left, int top, Paint paint, int digit) {
    for (int i = 0; i < kDigitWidthPixel; i++) {
      for (int j = 0; j < kDigitHeightPixel; j++) {
        if (DigitPathCalculate.onDigitPath(
            digit, i, j, kDigitWidthPixel, kDigitHeightPixel)) {
          _drawCircleAt(canvas, left + i, top + j, paint);
          _drawTextAt(left + i, top + j, highlightedTextStyle, canvas);
        }
      }
    }
  }
}