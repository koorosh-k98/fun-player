import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntityProvider extends ChangeNotifier {
  FileSystemEntity? _entity;

  FileSystemEntity? get entity => _entity;

  setEntity(FileSystemEntity entity) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("entity", entity.path);
    _entity = entity;
    notifyListeners();
  }
}
