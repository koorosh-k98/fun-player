import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player/play_music_provider.dart';

import 'entity_provider.dart';

class PlayScreen extends ConsumerStatefulWidget {
  PlayScreen({required this.entity, Key? key}) : super(key: key);
  FileSystemEntity? entity;

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  final playProvider = ChangeNotifierProvider((_) => PlayMusicProvider());

  // final entityProvider = ChangeNotifierProvider((_) => EntityProvider());

  @override
  void initState() {
    super.initState();
    ref.read(playProvider).getMetadata(widget.entity!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(builder: (context, ref, _) {
        return ref.watch(playProvider).artwork == null
            ? Container(
                color: Colors.black12,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: const Icon(Icons.music_note),
                ),
              )
            : SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.memory(ref.read(playProvider).artwork!),
                ),
              );
      }),
    );
  }
}
