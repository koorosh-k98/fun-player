import 'dart:io';
import 'dart:typed_data';

import 'package:audiotagger/models/tag.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:player/play_music_provider.dart';

class PlayScreen extends ConsumerStatefulWidget {
  PlayScreen(
      {required this.entity,
      required this.artwork,
      required this.tag,
      Key? key})
      : super(key: key);

  FileSystemEntity? entity;
  Uint8List? artwork;
  Tag? tag;

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  final playProvider = ChangeNotifierProvider((_) => PlayMusicProvider());

  @override
  void initState() {
    super.initState();
    print(
        "Taaaaaaaaaaaaaaaaaaaaaaaaggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
    print("artist: ${widget.tag?.artist}");
    print("title: ${widget.tag?.title}");
    print("artwork: ${widget.tag?.artwork}");
    print("album: ${widget.tag?.album}");
    print("albumArtist: ${widget.tag?.albumArtist}");
    print("comment: ${widget.tag?.comment}");
    print("discNumber: ${widget.tag?.discNumber}");
    print("genre: ${widget.tag?.genre}");
    print("year: ${widget.tag?.year}");
    print("discTotal: ${widget.tag?.discTotal}");
    print("lyrics: ${widget.tag?.lyrics}");
    print("trackNumber: ${widget.tag?.trackNumber}");
    print("trackTotal: ${widget.tag?.trackTotal}");
    print(
        "Taaaaaaaaaaaaaaaaaaaaaaaaggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
    // ref.read(playProvider).getMetadata(widget.entity!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(builder: (context, ref, _) {
        return Container(
          color: Colors.white60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              artwork(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                height: 50,
                child: Marquee(
                  text: (widget.tag?.title != ""
                      ? widget.tag?.title
                      : FileManager.basename(widget.entity))!,
                  style: const TextStyle(
                    fontSize: 35,
                    color: Colors.green,
                  ),
                ),
              ),
              Text(
                textAlign: TextAlign.center,
                widget.tag?.artist ?? "Unknown artist",
                style: const TextStyle(fontSize: 35),
              ),
              const Spacer(),
              Container(
                color: Colors.amber,
                width: double.infinity,
                height: 250,
                child: const Icon(Icons.pause),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget artwork() {
    return widget.artwork == null
        ? Container(
      width: double.infinity,
          height: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: const Icon(Icons.music_note, size: 150),
          ),
        )
        : SizedBox(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.memory(widget.artwork!),
            ),
          );
  }
}
