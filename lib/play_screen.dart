import 'dart:async';
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
  final colorProvider = ChangeNotifierProvider((ref) => ColorProvider());
  double value = 0;

  Key _refreshKey = UniqueKey();

  void _handleLocalChanged() {
    _refreshKey = UniqueKey();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setColor();
      // startTimer();
      // setValue();
      addListenerToPosition();
    });
  }

  late var refPlayProvider;
  late var refEntityProvider;
  late var refColorProvider;

  @override
  void didChangeDependencies() {
    refPlayProvider = ref.read(widget.playProvider);
    refEntityProvider = ref.read(widget.entityProvider);
    refColorProvider = ref.read(colorProvider);
    super.didChangeDependencies();
  }

  addListenerToPosition() {
    refPlayProvider.assetsAudioPlayer.currentPosition.listen((event) async {
      refPlayProvider.setCurrentDuration();
      double total =
          double.parse(refPlayProvider.totalDuration.inMilliseconds.toString());
      if (total != 0) value = event.inSeconds / total * 100000;
      if (event.inMilliseconds >= total-500) {
        List playlist = refPlayProvider.playlist;
        int index = refPlayProvider.pIndex;
        if (playlist.length - 1 == index) {
          refPlayProvider.pause();
           refPlayProvider.seek(0.0);
        } else {
          if (index < playlist.length - 1) {
            index++;
          }
          myPlay(index, playlist[index], playlist);
        }
      }
    });
  }



  // setValue() {
  //   if (ref.watch(widget.playProvider).totalDuration.inSeconds != 0) {
  //     setState(() {
  //       value = ref.read(widget.playProvider).currentDuration.inSeconds /
  //           ref.read(widget.playProvider).totalDuration.inSeconds *
  //           100.0;
  //     });
  //   } else {
  //     setState(() {
  //       value = 0;
  //     });
  //   }
  // }

  // late Timer _timer;
  //
  // void startTimer() {
  //   const oneSec = Duration(seconds: 1);
  //   _timer = Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       ref.read(widget.playProvider).setCurrentDuration();
  //       setValue();
  //     },
  //   );
  // }
  //
  // @override
  // void dispose() {
  //   // cancelListenerToPosition();
  //   super.dispose();
  // }

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
              const SizedBox(
                height: 10,
              ),
              artwork(width: w),
              const SizedBox(
                height: 35,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                height: 40,
                child: Marquee(
                  key: _refreshKey,
                  // startAfter: const Duration(seconds: 3),
                  startPadding: 50,
                  text: (ref.read(widget.playProvider).tag.title != ""
                      ? ref.read(widget.playProvider).tag.title
                      : FileManager.basename(
                          ref.read(widget.entityProvider).entity))!,
                  style: TextStyle(
                    fontSize: 25,
                    color: ref.watch(colorProvider).textColor,
                  ),
                  blankSpace: w,

                  // pauseAfterRound: const Duration(seconds: 3),
                  fadingEdgeStartFraction: 0.1,
                  fadingEdgeEndFraction: 0.1,
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
                    fontSize: 17,
                    color: ref.watch(colorProvider).textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Column(
                  children: [
                    Slider(
                      min: 0,
                      max: 100,
                      value: value == double.nan ? 0 : value,
                      thumbColor: Colors.blueGrey,
                      activeColor: ref.watch(colorProvider).textColor,
                      onChanged: (val) {
                        setState(() {
                          value = val;
                          ref.read(widget.playProvider).seek(value);
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            intToTimeLeft(ref
                                .watch(widget.playProvider)
                                .currentDuration
                                .inSeconds),
                            style: TextStyle(
                                color: ref.watch(colorProvider).textColor),
                          ),
                          Text(
                            intToTimeLeft(ref
                                .watch(widget.playProvider)
                                .totalDuration
                                .inSeconds),
                            style: TextStyle(
                                color: ref.watch(colorProvider).textColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => ref
                              .read(widget.playProvider)
                              .seekBy(const Duration(seconds: -10)),
                          icon: Icon(
                            Icons.replay_10_rounded,
                            size: 50,
                            color: ref.watch(colorProvider).textColor,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: rewind,
                          icon: Icon(
                            Icons.skip_previous,
                            size: 50,
                            color: ref.watch(colorProvider).textColor,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              final myProvider = ref.read(widget.playProvider);

                              if (myProvider.isPlaying) {
                                myProvider.pause();
                                // _timer.cancel();
                              } else {
                                // startTimer();
                                myProvider.play(
                                    entity:
                                        refEntityProvider.entity);
                              }
                            },
                            icon: Icon(
                              ref.watch(widget.playProvider).isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 70,
                              color: ref.watch(colorProvider).textColor,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: forward,
                          icon: Icon(
                            Icons.skip_next,
                            size: 50,
                            color: ref.watch(colorProvider).textColor,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => ref
                              .read(widget.playProvider)
                              .seekBy(const Duration(seconds: 10)),
                          icon: Icon(
                            Icons.forward_10_rounded,
                            size: 50,
                            color: ref.watch(colorProvider).textColor,
                          ),
                        ),
                      ],
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
        ? Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.black12),
              width: double.infinity - 60,
              height: width - 60,
              child: Icon(
                Icons.music_note,
                size: 150,
                color: ref.watch(colorProvider).textColor,
              ),
            ),
          )
        : Container(
            width: double.infinity,
            height: width,
            padding: const EdgeInsets.all(30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.memory(ref.watch(widget.playProvider).artwork!),
            ),
          );
  }

  void setColor() async {
    PaletteGenerator paletteGenerator;
    if (refPlayProvider.artwork == null) {
      paletteGenerator =
          PaletteGenerator.fromColors([PaletteColor(Colors.white60, 0)]);
    } else {
      paletteGenerator = await PaletteGenerator.fromImageProvider(
        Image.memory(refPlayProvider.artwork!).image,
      );
    }
    Color backgroundColor =
        paletteGenerator.dominantColor?.color ?? Colors.white60;
    Color textColor = (backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white60);
    // ? paletteGenerator.darkMutedColor?.color
    // : paletteGenerator.lightMutedColor?.color)??
    // Colors.black;
    refColorProvider.setBackgroundColor(backgroundColor);
    refColorProvider.setTextColor(textColor);
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
    int index = ref.read(widget.playProvider).pIndex;
    if (index > 0) {
      index--;
    }
    myPlay(index, playlist[index], playlist);
  }

  void myPlay(int index, FileSystemEntity entity, List entities) async {
    _handleLocalChanged();
    FileSystemEntity? currentEntity = refEntityProvider.entity;
    if (currentEntity != entity) {
      refEntityProvider.setEntity(entity);
      await refPlayProvider.retrieveMetadata(entity);
      refPlayProvider.setPlaylist(entities);
      refPlayProvider.setPIndex(index);
      setColor();
    }
    await refPlayProvider.play(entity: entity);
    refPlayProvider.setTotalDuration();
  }

  // forward10s() {
  // double duration =
  //     double.parse(ref.read(widget.playProvider).currentDuration.inSeconds.toString());
  // print("duration: ${duration.toString()}");
  // double total = double.parse(ref.read(widget.playProvider).totalDuration.inSeconds.toString());
  // print("total: ${total.toString()}");
  // if (duration < total - 10.0) {
  //   duration += 10.0;
  //   ref.read(widget.playProvider).seek(duration/total);
  //   print("done: $duration");
  // }
  // }

  // rewind10s() {
  // double duration =
  //     double.parse(ref.read(widget.playProvider).currentDuration.inSeconds.toString());
  // double total = double.parse(ref.read(widget.playProvider).totalDuration.inSeconds.toString());
  // print("duration: ${duration.toString()}");
  // if (duration > 10) {
  //   duration -= 10;
  //   ref.read(widget.playProvider).seek(duration/total);
  // }
  // }

  String intToTimeLeft(int value) {
    int h, m, s;
    h = value ~/ 3600;
    m = ((value - h * 3600)) ~/ 60;
    s = value - (h * 3600) - (m * 60);
    String hourLeft = h.toString().length < 2 ? "0$h" : h.toString();
    String minuteLeft = m.toString().length < 2 ? "0$m" : m.toString();
    String secondsLeft = s.toString().length < 2 ? "0$s" : s.toString();
    String result = "$hourLeft:$minuteLeft:$secondsLeft";
    return result;
  }
}
