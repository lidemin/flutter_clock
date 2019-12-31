import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'digit_path_calculate.dart';

class ClockDigitLayer extends StatefulWidget {
  @override
  _ClockDigitLayerState createState() => _ClockDigitLayerState();
}

class _ClockDigitLayerState extends State<ClockDigitLayer>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DigitsContainer(
      controller: _controller,
    );
  }
}

class DigitsContainer extends AnimatedWidget {
  const DigitsContainer({Key key, AnimationController controller})
      : super(key: key, listenable: controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        size: Size.infinite,
        painter: ClockPainter(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}

const int kTotalDigits = 6;

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

final circlePaint = Paint()..color = Colors.red.withOpacity(0.5);
final clockPaint = Paint()..color = Colors.green.withOpacity(0.05);
final centerPaint = Paint()..color = Colors.blue.withOpacity(0.8);
final digitPaint = Paint()..color = Colors.green.withOpacity(0.8);

class ClockPainter extends CustomPainter {
  final int _currentTimestamp;
  int _lastDrawTimestamp = 0;
  ClockPainter(this._currentTimestamp);

  @override
  void paint(Canvas canvas, Size size) {
    if (lastSize != size) {
      lastSize = size;
      _reCalculate(size);
    }

    _lastDrawTimestamp = DateTime.now().microsecondsSinceEpoch;

    _drawDigits(
        canvas, digitPaint, intl.DateFormat("HHmmss").format(DateTime.now()));
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
  bool shouldRepaint(ClockPainter oldDelegate) {
    return _currentTimestamp - oldDelegate._lastDrawTimestamp > 150;
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
          // _drawTextAt(canvas, left + i, top + j, highlightedTextStyle);
        }
      }
    }
  }
}
