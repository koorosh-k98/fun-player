import 'package:flutter/material.dart';

class TitleProvider extends ChangeNotifier {
  String? _title;

  String? get title => _title;

  set setTitle(title) {
    _title = title;
    notifyListeners();
  }
}
