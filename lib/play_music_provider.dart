import 'dart:io';
import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayMusicProvider extends ChangeNotifier {
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  final _assetsAudioPlayer = AssetsAudioPlayer();

  get assetsAudioPlayer => _assetsAudioPlayer;

  FileSystemEntity? classEntity;

  Uint8List? _artwork;

  List _artworks = [];

  // int _length = 0;

  Tag? _tag;

  Tag? get tag => _tag;

  Uint8List? get artwork => _artwork;

  List get artworks => _artworks;

  // int get length => _length;

  List _playList = [];

  List get playlist => _playList;

  int _pIndex = 0;

  int get pIndex => _pIndex;

  Duration _totalDuration = const Duration(seconds: 0);

  Duration get totalDuration => _totalDuration;

  Duration _currentDuration = const Duration(seconds: 0);

  Duration get currentDuration => _currentDuration;

  double _sliderValue = 0.0;

  double get sliderValue => _sliderValue;

  double _speed = 1.0;

  double get speed => _speed;

  increaseSpeed() {
    if (_speed <= 5.9) {
      _speed += 0.1;
      _assetsAudioPlayer.setPlaySpeed(_speed);
      notifyListeners();
    }
  }

  decreaseSpeed() {
    if (_speed >= 0.2) {
      _speed -= 0.1;
      _assetsAudioPlayer.setPlaySpeed(_speed);
      notifyListeners();
    }
  }

  resetSpeed() {
    _speed = 1.0;
    _assetsAudioPlayer.setPlaySpeed(_speed);
    notifyListeners();
  }

  play(
      {required FileSystemEntity? entity,
      Function? next,
      Function? prev}) async {
    if (classEntity == entity) {
      _assetsAudioPlayer.play();
    } else {
      classEntity = entity;
      Metas metas = Metas(
        title: _tag?.title != "" ? _tag?.title : FileManager.basename(entity),
        artist: _tag?.artist ?? "Unknown artist",
        image: MetasImage.file(artwork.toString()),
      );
      _assetsAudioPlayer.open(
        Audio.file(entity!.path, metas: metas),
        headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplug,
        playInBackground: PlayInBackground.enabled,
        showNotification: true,
        notificationSettings: NotificationSettings(
            customNextAction: (aap) => next!(),
            customPrevAction: (aap) => prev!()),
      );
    }
    _isPlaying = true;
    notifyListeners();
  }

  pause() {
    _isPlaying = false;
    _assetsAudioPlayer.pause();
    notifyListeners();
  }

  pausePlaying() {
    _isPlaying = false;
    notifyListeners();
  }

  startPlaying() {
    _isPlaying = true;
    notifyListeners();
  }

  setTotalDuration() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _totalDuration = _assetsAudioPlayer.current.valueOrNull?.audio.duration ??
          const Duration(seconds: 0);
      notifyListeners();
    });
  }

  setCurrentDuration() {
    _currentDuration = _assetsAudioPlayer.currentPosition.valueOrNull ??
        const Duration(seconds: 0);

    notifyListeners();
  }

  setSliderValue(event) {
    double total = double.parse(totalDuration.inMilliseconds.toString());
    total != 0 ? _sliderValue = event.inSeconds / total * 100000 : 0.0;
    notifyListeners();
  }

  seek(double to) {
    double position = to / 100 * totalDuration.inSeconds;
    _assetsAudioPlayer.seek(Duration(seconds: position.round()));
    // setCurrentDuration();
  }

  seekBy(duration) {
    _assetsAudioPlayer.seekBy(duration);
  }

  retrieveMetadata(entity) async {
    _artwork = null;

    if (FileManager.getFileExtension(entity).toLowerCase() == "mp3") {
      final tagger = Audiotagger();
      _tag = await tagger.readTags(path: entity.path);
      _artwork = await tagger.readArtwork(path: entity.path);
    }
    notifyListeners();
  }

  retrieveArtworks(List entities) async {
    _artworks = List.generate(entities.length, (index) => null);
    final tagger = Audiotagger();
    for (var e in entities) {
      if (FileManager.isFile(e) &&
          (FileManager.getFileExtension(e).toLowerCase() == "mp3")) {
        var artwork = await tagger.readArtwork(path: e.path);
        _artworks.insert(entities.indexOf(e), artwork);
        notifyListeners();
      }
    }
  }

  setPlaylist(List entities) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        "entities",
        entities.map((element) {
          return element.path.toString();
        }).toList());
    _playList = entities;
    notifyListeners();
  }

  setPIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("pIndex", index);
    _pIndex = index;
    notifyListeners();
  }

// setLength(int length) {
//   _length = length;
//   notifyListeners();
// }

// @override
// void dispose() {
//   super.dispose();
//   // _assetsAudioPlayer.dispose();
// }
}
