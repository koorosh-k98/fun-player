import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';

class PlayScreen extends StatefulWidget {
  PlayScreen({Key? key}) : super(key: key);

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Hi")),
    );
  }
}
