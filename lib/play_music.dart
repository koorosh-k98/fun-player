import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class PlayMusic extends ChangeNotifier {
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  final assetsAudioPlayer = AssetsAudioPlayer();

  FileSystemEntity? entity;

  PlayMusic([this.entity]);

  @override
  void dispose() {
    super.dispose();
    assetsAudioPlayer.dispose();
  }

  play() {
    assetsAudioPlayer.open(Audio.file(entity!.path));
    _isPlaying = true;
    notifyListeners();
  }

  pause() {
    _isPlaying = false;
    notifyListeners();
    assetsAudioPlayer.dispose();
  }
}
