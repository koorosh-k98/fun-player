import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';

class PlayScreen extends StatefulWidget {
  PlayScreen({required this.entity, Key? key}) : super(key: key);
  FileSystemEntity entity;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    assetsAudioPlayer.open(
      Audio.file(widget.entity.path),
    );
  }

  @override
  void dispose() {
    super.dispose();
    assetsAudioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text(FileManager.basename(widget.entity)),
      ),
    );
  }
}
