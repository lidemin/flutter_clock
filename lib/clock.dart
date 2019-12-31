import 'dart:math';

import 'package:clock/baijiaxing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'digit_path_calculate.dart';

class Clock extends StatefulWidget {
  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> with SingleTickerProviderStateMixin {
  int lastDrawTimestamp = 0;
  // if it is 25ms, it will be equivalent as 60+fps
  final int frameThrottling = 100;
  @override
  void initState() {
    super.initState();

    var controller = AnimationController(
        duration: Duration(milliseconds: 10000), vsync: this);

    var animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    animation.addListener(() {
      // drop frames within [frameThrottling]ms
      if (DateTime.now().millisecondsSinceEpoch - lastDrawTimestamp <
          frameThrottling) {
        return;
      }
      // might be able to replace this with pure ticker
      setState(() {
        lastDrawTimestamp = DateTime.now().millisecondsSinceEpoch;
      });
    });
    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomPaint(
        size: Size.infinite,
        painter: ClockPainter(lastDrawTimestamp),
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

var drops = List<Drop>();

TextStyle textStyle;
TextStyle highlightedTextStyle;

const int kDropLength = 50;
const int kConcurrentDrops = 10;
var dropTextColors = List(kDropLength);

class ClockPainter extends CustomPainter {
  final int _lastDrawTimestamp;
  ClockPainter(this._lastDrawTimestamp) {
    for (int i = 0; i < kConcurrentDrops; i++) {
      drops.add(Drop()..reset());
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (lastSize != size) {
      lastSize = size;
      _reCalculate(size);
    }

    // for (int i = 0; i < actualTotalWidthPixel; i++) {
    //   for (int j = 0; j < actualTotalHeightPixel; j++) {
    //     // draw circles as guideline
    //     if (i == centerPixelDx && j == centerPixelDy) {
    //       // _drawCircleAt(canvas, i, j, centerPaint);
    //     } else if (i >= clockLeft &&
    //         i <= clockRight &&
    //         j >= clockTop &&
    //         j <= clockBottom) {
    //       // _drawCircleAt(canvas, i, j, clockPaint);
    //     } else {
    //       // _drawCircleAt(canvas, i, j, circlePaint);
    //     }

    //     // draw background text
    //     // _drawTextAt(i, j, textStyle, canvas);
    //   }
    // }

    for (int i = 0; i < kConcurrentDrops; i++) {
      int left = drops[i].column % actualTotalWidthPixel;
      int top = drops[i].rowOfCurrentBottom;
      for (int j = 0; j < kDropLength; j++) {
        _drawTextAt(canvas, left, top - j, dropTextColors[j]);
      }
      // calculate next frame of this drop
      if (top - kDropLength > actualTotalHeightPixel) {
        drops[i].reset();
      }

      drops[i].rowOfCurrentBottom += drops[i].rowInterval;
      drops[i].lastRenderTimestamp = _lastDrawTimestamp;
    }

    _drawDigits(
        canvas, digitPaint, intl.DateFormat("HHmmss").format(DateTime.now()));

    // _fractions.forEach((index, fraction) {
    //   int left = index % actualTotalWidthPixel;
    //   int top = (actualTotalHeightPixel * fraction).floor();
    //   for (int j = 0; j < kDropLength; j++) {
    //     _drawTextAt(canvas, left, top - (j * (1 - fraction / 2)).floor(),
    //         dropTextColors[min((j * (1 + fraction)).floor(), kDropLength - 1)]);
    //   }
    // });
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

    for (int i = 0; i < kDropLength; i++) {
      dropTextColors[i] = textStyle.apply(
          color: Colors.green.withOpacity(0.9 * (1 - i / kDropLength)));
    }

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
    return oldDelegate._lastDrawTimestamp != _lastDrawTimestamp;
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

class Drop {
  int column;
  int rowOfCurrentBottom;
  int length;
  int lastRenderTimestamp;
  int rowInterval;

  reset() {
    var random = Random(DateTime.now().millisecondsSinceEpoch);
    column = random.nextInt(1000);
    rowOfCurrentBottom = 0;
    length = random.nextInt(20) + 20;
    lastRenderTimestamp = 0;
    rowInterval = random.nextInt(3) + 1; //
  }
}
