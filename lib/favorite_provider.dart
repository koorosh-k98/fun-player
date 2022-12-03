import 'dart:io';

import 'package:flutter/material.dart';

class FavoriveProvider extends ChangeNotifier {
  List _favorites = [];

  bool _isFavorite = false;

  List get favorites => _favorites;

  bool get isFavorite => _isFavorite;

  checkFavorite(FileSystemEntity entity) {
    _isFavorite = _favorites.contains(entity);
    notifyListeners();
  }

  add(FileSystemEntity entity) {
    _favorites.add(entity);
    checkFavorite(entity);
  }

  remove(FileSystemEntity entity) {
    _favorites.remove(entity);
    checkFavorite(entity);
  }
}
