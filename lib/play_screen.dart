import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:player/color_provider.dart';

class PlayScreen extends ConsumerStatefulWidget {
  PlayScreen(
      {
      //   required this.entity,
      // required this.artwork,
      // required this.tag,
      required this.playProvider,
      required this.entityProvider,
      Key? key})
      : super(key: key);

  // FileSystemEntity? entity;
  // Uint8List? artwork;
  // Tag? tag;
  final playProvider;
  final entityProvider;

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  // Color backgroundColor = Colors.white60;
  // Color textColor = Colors.black;
  final colorProvider = ChangeNotifierProvider((ref) => ColorProvider());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setColor();
    });

    // print(
    //     "Taaaaaaaaaaaaaaaaaaaaaaaaggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
    // print("artist: ${ref.read(widget.playProvider).tag.artist}");
    // print("title: ${ref.read(widget.playProvider).tag.title}");
    // print("artwork: ${ref.read(widget.playProvider).tag.artwork}");
    // print("album: ${ref.read(widget.playProvider).tag.album}");
    // print("albumArtist: ${ref.read(widget.playProvider).tag.albumArtist}");
    // print("comment: ${ref.read(widget.playProvider).tag.comment}");
    // print("discNumber: ${ref.read(widget.playProvider).tag.discNumber}");
    // print("genre: ${ref.read(widget.playProvider).tag.genre}");
    // print("year: ${ref.read(widget.playProvider).tag.year}");
    // print("discTotal: ${ref.read(widget.playProvider).tag.discTotal}");
    // print("lyrics: ${ref.read(widget.playProvider).tag.lyrics}");
    // print("trackNumber: ${ref.read(widget.playProvider).tag.trackNumber}");
    // print("trackTotal: ${ref.read(widget.playProvider).tag.trackTotal}");
    // print(
    //     "Taaaaaaaaaaaaaaaaaaaaaaaaggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
    // ref.read(widget.playProvider).getMetadata(widget.entity!);
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Consumer(builder: (context, ref, _) {
        return Container(
          color: ref.watch(colorProvider).backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              artwork(width: w),
              const SizedBox(
                height: 35,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                height: 50,
                child: Marquee(
                  text: (ref.read(widget.playProvider).tag.title != ""
                      ? ref.read(widget.playProvider).tag.title
                      : FileManager.basename(
                          ref.read(widget.entityProvider).entity))!,
                  style: TextStyle(
                    fontSize: 35,
                    color: ref.watch(colorProvider).textColor,
                  ),
                  blankSpace: w,
                  fadingEdgeStartFraction: 0.2,
                  fadingEdgeEndFraction: 0.2,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: w,
                height: 80,
                child: Text(
                  ref.read(widget.playProvider).tag.artist ?? "Unknown artist",
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: ref.watch(colorProvider).textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Container(
                // color: Colors.amber,
                width: double.infinity,
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "-10s",
                      style: TextStyle(
                          color: ref.watch(colorProvider).textColor,
                          fontSize: 25),
                    ),
                    IconButton(
                      onPressed: rewind,
                      icon: Icon(
                        Icons.fast_rewind,
                        size: 50,
                        color: ref.watch(colorProvider).textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final myProvider = ref.read(widget.playProvider);

                        if (myProvider.isPlaying) {
                          myProvider.pause();
                        } else {
                          myProvider.play(
                              entity: ref.read(widget.entityProvider).entity);
                        }
                      },
                      icon: Icon(
                        ref.watch(widget.playProvider).isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 50,
                        color: ref.watch(colorProvider).textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: forward,
                      icon: Icon(
                        Icons.fast_forward_sharp,
                        size: 50,
                        color: ref.watch(colorProvider).textColor,
                      ),
                    ),
                    Text(
                      "+10s",
                      style: TextStyle(
                          color: ref.watch(colorProvider).textColor,
                          fontSize: 25),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget artwork({width}) {
    return ref.read(widget.playProvider).artwork == null
        ? SizedBox(
            width: double.infinity,
            height: width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Icon(
                Icons.music_note,
                size: 150,
                color: ref.watch(colorProvider).textColor,
              ),
            ),
          )
        : SizedBox(
            width: double.infinity,
            height: width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.memory(ref.watch(widget.playProvider).artwork!),
            ),
          );
  }

  void setColor() async {
    PaletteGenerator paletteGenerator;
    if (ref.read(widget.playProvider).artwork == null) {
      paletteGenerator =
          PaletteGenerator.fromColors([PaletteColor(Colors.white60, 0)]);
    } else {
      paletteGenerator = await PaletteGenerator.fromImageProvider(
        Image.memory(ref.read(widget.playProvider).artwork!).image,
      );
    }
    Color backgroundColor =
        paletteGenerator.dominantColor?.color ?? Colors.white60;
    Color textColor = (backgroundColor.computeLuminance() > 0.5
            ? paletteGenerator.darkMutedColor?.color
            : paletteGenerator.lightMutedColor?.color) ??
        Colors.black;
    ref.read(colorProvider).setBackgroundColor(backgroundColor);
    ref.read(colorProvider).setTextColor(textColor);
  }

  forward() {
    List playlist = ref.read(widget.playProvider).playlist;
    int index = ref.read(widget.playProvider).pIndex;
    if (index < playlist.length - 1) {
      index++;
    }
    myPlay(index, playlist[index], playlist);
  }

  rewind() {
    List playlist = ref.read(widget.playProvider).playlist;
    playlist.map((e) {
      print("e: $e\n");
    });
    int index = ref.read(widget.playProvider).pIndex;
    if (index > 0) {
      index--;
    }
    print("index: $index");
    myPlay(index, playlist[index], playlist);
  }

  void myPlay(int index, FileSystemEntity entity, List entities) async {
    FileSystemEntity? currentEntity = ref.read(widget.entityProvider).entity;
    if (currentEntity != entity) {
      ref.read(widget.entityProvider).setEntity(entity);
      await ref.read(widget.playProvider).retrieveMetadata(entity);
      ref.read(widget.playProvider).setPlaylist(entities);
      ref.read(widget.playProvider).setPIndex(index);
      setColor();
    }
    ref.read(widget.playProvider).play(entity: entity);
  }
}
