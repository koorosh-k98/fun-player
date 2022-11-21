import 'dart:io';

import 'package:flutter/material.dart';

class EntityProvider extends ChangeNotifier {
  FileSystemEntity? _entity;

  FileSystemEntity? get entity => _entity;

  setEntity(FileSystemEntity entity) {
    _entity = entity;
    notifyListeners();
  }
}
