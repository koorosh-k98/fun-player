import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player/entity_provider.dart';

class PlayMusicProvider extends ChangeNotifier {
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  final assetsAudioPlayer = AssetsAudioPlayer();

  FileSystemEntity? classEntity;

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

  @override
  void dispose() {
    super.dispose();
    assetsAudioPlayer.dispose();
  }
}
