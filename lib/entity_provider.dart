import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntityProvider extends ChangeNotifier {
  FileSystemEntity? _entity;

  List _entities = [];

  FileSystemEntity? get entity => _entity;

  List get entities => _entities;

  setEntity(FileSystemEntity entity) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("entity", entity.path);
    _entity = entity;
    notifyListeners();
  }

  setEntities(List entities) {
    _entities = entities;
    notifyListeners();
  }
}
