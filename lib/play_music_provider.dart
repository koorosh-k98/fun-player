import 'dart:io';
import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';

class PlayMusicProvider extends ChangeNotifier {
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  final _assetsAudioPlayer = AssetsAudioPlayer();

  get assetsAudioPlayer => _assetsAudioPlayer;

  FileSystemEntity? classEntity;

  Uint8List? _artwork;

  List _artworks = [];

  int _length = 0;

  Tag? _tag;

  Tag? get tag => _tag;

  Uint8List? get artwork => _artwork;

  List get artworks => _artworks;

  int get length => _length;

  List _playList = [];

  List get playlist => _playList;

  int _pIndex = 0;

  int get pIndex => _pIndex;

  Duration _totalDuration = const Duration(seconds: 0);

  Duration get totalDuration => _totalDuration;

  Duration _currentDuration = const Duration(seconds: 0);

  Duration get currentDuration => _currentDuration;

  play({required FileSystemEntity? entity}) {
    if (classEntity == entity) {
      _assetsAudioPlayer.play();
    } else {
      classEntity = entity;
      _assetsAudioPlayer.open(Audio.file(entity!.path));
    }
    _isPlaying = true;
    notifyListeners();
  }

  pause() {
    _isPlaying = false;
    notifyListeners();
    _assetsAudioPlayer.pause();
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

  seek(double to) {
    setCurrentDuration();
    double position = to / 100 * totalDuration.inSeconds;
    _assetsAudioPlayer.seek(Duration(seconds: position.round()));
  }

  seekBy(duration) {
    _assetsAudioPlayer.seekBy(duration);
  }

  retrieveMetadata(entity) async {
    _artwork = null;

    if (FileManager.getFileExtension(entity) == "mp3") {
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
      if (FileManager.isFile(e) && FileManager.getFileExtension(e) == "mp3") {
        var artwork = await tagger.readArtwork(path: e.path);
        _artworks.insert(entities.indexOf(e), artwork);
        notifyListeners();
      }
    }
  }

  setPlaylist(List entities) {
    _playList = entities;
    notifyListeners();
  }

  setPIndex(int index) {
    _pIndex = index;
    notifyListeners();
  }

  setLength(int length) {
    _length = length;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _assetsAudioPlayer.dispose();
  }


}
