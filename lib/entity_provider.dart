import 'dart:io';

import 'package:flutter/material.dart';

class EntityProvider extends ChangeNotifier {
  FileSystemEntity? _entity;

  List _entities = [];

  FileSystemEntity? get entity => _entity;

  List get entities => _entities;

  setEntity(FileSystemEntity entity) {
    _entity = entity;
    notifyListeners();
  }

  setEntities(List entities) {
    _entities = entities;
    notifyListeners();
  }
}
