import 'package:flutter/widgets.dart';

class ColorProvider extends ChangeNotifier {
  Color? _backgroundColor;
  Color? _textColor;

  Color? get backgroundColor => _backgroundColor;

  Color? get textColor => _textColor;

  setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  setTextColor(Color color) {
    _textColor = color;
    notifyListeners();
  }
}
