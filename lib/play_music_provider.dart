import 'dart:io';
import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entity_provider.dart';

class PlayMusicProvider extends ChangeNotifier {



  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  final assetsAudioPlayer = AssetsAudioPlayer();

  FileSystemEntity? classEntity;

  Uint8List? _artwork;

  Tag? _tag;

  Tag? get tag => _tag;

  Uint8List? get artwork => _artwork;

  List _entities = [];

  List get playlist => _entities;

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

  getMetadata(entity) async {
    _artwork = null;

    if (FileManager.getFileExtension(entity) == "mp3") {
      final tagger = Audiotagger();
      _tag = await tagger.readTags(path: entity.path);
      _artwork = await tagger.readArtwork(path: entity.path);
      print(
          "Taaaaaaaaaaaaaaaaaaaaaaaaggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
      print("artist: ${_tag?.artist}");
      print("title: ${_tag?.title}");
      print("artwork: ${_tag?.artwork}");
      print("album: ${_tag?.album}");
      print("albumArtist: ${_tag?.albumArtist}");
      print("comment: ${_tag?.comment}");
      print("discNumber: ${_tag?.discNumber}");
      print("genre: ${_tag?.genre}");
      print("year: ${_tag?.year}");
      print("discTotal: ${_tag?.discTotal}");
      print("lyrics: ${_tag?.lyrics}");
      print("trackNumber: ${_tag?.trackNumber}");
      print("trackTotal: ${_tag?.trackTotal}");
      print(
          "Taaaaaaaaaaaaaaaaaaaaaaaaggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
    }
    notifyListeners();
  }

  getArtworks(List entities) {}

  setPlaylist(List entities) {
    _entities = entities;
    notifyListeners();
  }

  setPIndex(int index) {
    _pIndex = index;
    notifyListeners();
  }


  @override
  void dispose() {
    super.dispose();
    assetsAudioPlayer.dispose();
  }
}
