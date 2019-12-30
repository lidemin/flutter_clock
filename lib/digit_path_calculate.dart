class DigitPathCalculate {
  static bool onDigitPath(
      int digit, int x, int y, int digitWidth, int digitHeight) {
    switch (digit) {
      case 0:
        return _onDigitPathWithParams(x, y, digitWidth, digitHeight,
            top: true, left: true, right: true, bottom: true);

      case 1:
        return _onDigitPathWithParams(x, y, digitWidth, digitHeight,
            right: true);
      case 2:
        return _onDigitPathWithParams(x, y, digitWidth, digitHeight,
            top: true,
            middle: true,
            bottom: true,
            topRight: true,
            bottomLeft: true);
      case 3:
        return _onDigitPathWithParams(x, y, digitWidth, digitHeight,
            top: true, middle: true, bottom: true, right: true);

      case 4:
        return _onDigitPathWithParams(x, y, digitWidth, digitHeight,
            topLeft: true, right: true, middle: true);
      case 5:
        return _onDigitPathWithParams(x, y, digitWidth, digitHeight,
            top: true,
            middle: true,
            bottom: true,
            topLeft: true,
            bottomRight: true);
      case 6:
        return _onDigitPathWithParams(x, y, digitWidth, digitHeight,
            top: true,
            middle: true,
            bottom: true,
            left: true,
            bottomRight: true);
      case 7:
        return _onDigitPathWithParams(x, y, digitWidth, digitHeight,
            top: true, right: true);
      case 8:
        return _onDigitPathWithParams(x, y, digitWidth, digitHeight,
            top: true, left: true, right: true, bottom: true, middle: true);
      case 9:
        return _onDigitPathWithParams(x, y, digitWidth, digitHeight,
            top: true, topLeft: true, right: true, bottom: true, middle: true);
    }
    return false;
  }

  static bool _onDigitPathWithParams(x, y, digitWidth, digitHeight,
      {top = false,
      middle = false,
      bottom = false,
      left = false,
      right = false,
      topLeft = false,
      bottomLeft = false,
      topRight = false,
      bottomRight = false}) {
    return (top ? _onDigitTopPath(x, y, digitWidth, digitHeight) : false) ||
        (middle ? _onDigitMiddlePath(x, y, digitWidth, digitHeight) : false) ||
        (bottom ? _onDigitBottomPath(x, y, digitWidth, digitHeight) : false) ||
        (left ? _onDigitLeftPath(x, y, digitWidth, digitHeight) : false) ||
        (right ? _onDigitRightPath(x, y, digitWidth, digitHeight) : false) ||
        (topLeft
            ? _onDigitTopLeftPath(x, y, digitWidth, digitHeight)
            : false) ||
        (bottomLeft
            ? _onDigitBottomLeftPath(x, y, digitWidth, digitHeight)
            : false) ||
        (topRight
            ? _onDigitTopRightPath(x, y, digitWidth, digitHeight)
            : false) ||
        (bottomRight
            ? _onDigitBottomRightPath(x, y, digitWidth, digitHeight)
            : false);
  }

  static bool _onDigitTopPath(int x, int y, int digitWidth, int digitHeight) {
    return (y == 0 && (x >= 0 && x < digitWidth));
  }

  static bool _onDigitBottomPath(
      int x, int y, int digitWidth, int digitHeight) {
    return (y == digitHeight - 1 && (x >= 0 && x < digitWidth));
  }

  static bool _onDigitMiddlePath(
      int x, int y, int digitWidth, int digitHeight) {
    return (y == (digitHeight / 2).floor() && (x >= 0 && x < digitWidth));
  }

  static bool _onDigitTopLeftPath(
      int x, int y, int digitWidth, int digitHeight) {
    return (x == 0 && (y >= 0 && y < digitHeight / 2));
  }

  static bool _onDigitBottomLeftPath(
      int x, int y, int digitWidth, int digitHeight) {
    return (x == 0 && (y > digitHeight / 2 && y < digitHeight));
  }

  static bool _onDigitTopRightPath(
      int x, int y, int digitWidth, int digitHeight) {
    return (x == digitWidth - 1 && (y >= 0 && y < digitHeight / 2));
  }

  static bool _onDigitBottomRightPath(
      int x, int y, int digitWidth, int digitHeight) {
    return (x == digitWidth - 1 && (y >= digitHeight / 2 && y < digitHeight));
  }

  static bool _onDigitLeftPath(int x, int y, int digitWidth, int digitHeight) {
    return _onDigitTopLeftPath(x, y, digitWidth, digitHeight) ||
        _onDigitBottomLeftPath(x, y, digitWidth, digitHeight);
  }

  static bool _onDigitRightPath(int x, int y, int digitWidth, int digitHeight) {
    return _onDigitTopRightPath(x, y, digitWidth, digitHeight) ||
        _onDigitBottomRightPath(x, y, digitWidth, digitHeight);
  }
}
