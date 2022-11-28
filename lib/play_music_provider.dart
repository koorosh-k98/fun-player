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

  final assetsAudioPlayer = AssetsAudioPlayer();

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

  play({required FileSystemEntity? entity}) {
    if (classEntity == entity) {
      assetsAudioPlayer.play();
    } else {
      classEntity = entity;
      assetsAudioPlayer.open(Audio.file(entity!.path));
    }
    _isPlaying = true;
    notifyListeners();
  }

  pause() {
    _isPlaying = false;
    notifyListeners();
    assetsAudioPlayer.pause();
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
    assetsAudioPlayer.dispose();
  }
}
