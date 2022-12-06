import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriveProvider extends ChangeNotifier {
  List _favorites = [];

  bool _isFavorite = false;

  List get favorites => _favorites;

  bool get isFavorite => _isFavorite;

  checkFavorite(FileSystemEntity entity) {
    _isFavorite = _favorites.contains(entity);
    notifyListeners();
  }

  add(FileSystemEntity entity) async {
    final prefs = await SharedPreferences.getInstance();
    _favorites.add(entity);
    checkFavorite(entity);
    prefs.setStringList(
        "favorites",
        _favorites.map((element) {
          return element.path.toString();
        }).toList());
  }

  remove(FileSystemEntity entity) async {
    final prefs = await SharedPreferences.getInstance();
    _favorites.remove(entity);
    checkFavorite(entity);
    prefs.setStringList(
        "favorites",
        _favorites.map((element) {
          return element.path.toString();
        }).toList());
  }
}
