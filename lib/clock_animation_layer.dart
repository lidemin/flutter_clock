import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import 'digit_path_calculate.dart';

class ClockAnimationLayer extends StatefulWidget {
  @override
  _ClockAnimationLayerState createState() => _ClockAnimationLayerState();
}

class _ClockAnimationLayerState extends State<ClockAnimationLayer>
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
    return ClockAnimationContainer(
      controller: _controller,
    );
  }
}

class ClockAnimationContainer extends AnimatedWidget {
  const ClockAnimationContainer({Key key, AnimationController controller})
      : super(key: key, listenable: controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: ClockAnimationPainter(DateTime.now().millisecondsSinceEpoch),
        ),
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

const int kConcurrentDrops = 10;
// const int kDropLength = 50;

Size lastSize;
var drops = List<Drop>();

final linearGradient = LinearGradient(
  colors: [
    // Colors.black.withOpacity(1),
    // Colors.black.withOpacity(1),
    Colors.black.withOpacity(0.1),
    Colors.black.withOpacity(0.9),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

class ClockAnimationPainter extends CustomPainter {
  final int _currentTimestamp;
  int _lastDrawTimestamp = 0;

  ClockAnimationPainter(this._currentTimestamp) {
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

    _lastDrawTimestamp = DateTime.now().microsecondsSinceEpoch;

    for (int i = 0; i < kConcurrentDrops; i++) {
      int left = drops[i].index % actualTotalWidthPixel;
      int top = drops[i].currentHead - drops[i].length;
      Rect rect = Rect.fromLTWH(
        left * squareSize.toDouble() + paddingHorizontal,
        top * squareSize.toDouble() + paddingVertical,
        squareSize.toDouble(),
        drops[i].length * squareSize.toDouble() + actualTotalHeightPixel,
      );
      canvas.drawRect(
          rect, Paint()..shader = linearGradient.createShader(rect));

      // calculate next frame of this drop
      if (top > actualTotalHeightPixel) {
        drops[i].reset();
      }

      drops[i].currentHead += 1;
    }
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

  @override
  bool shouldRepaint(ClockAnimationPainter oldDelegate) {
    return _currentTimestamp - oldDelegate._lastDrawTimestamp > 4000;
  }
}

class Drop {
  int index;
  int currentHead;
  int length;
  int rowInterval;

  reset() {
    var random = Random(DateTime.now().millisecondsSinceEpoch);
    index = random.nextInt(1000);
    currentHead = 0;
    length = random.nextInt(10) + 5;
    rowInterval = random.nextInt(3) + 1; //
  }
}
