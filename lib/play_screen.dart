import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:player/color_provider.dart';

class PlayScreen extends ConsumerStatefulWidget {
  PlayScreen(
      {required this.playProvider,
      required this.entityProvider,
      required this.favoriteProvider,
      Key? key})
      : super(key: key);

  final playProvider;
  final entityProvider;
  final favoriteProvider;

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen>
    with SingleTickerProviderStateMixin {
  final colorProvider = ChangeNotifierProvider((ref) => ColorProvider());

  late var refPlayProvider;
  late var refEntityProvider;
  late var refColorProvider;
  double speed = 1.0;

  AnimationController? animationController;
  Animation<double>? sizeAnimation;

  double value = 0;

  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    animation();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setColor();
      ref
          .read(widget.favoriteProvider)
          .checkFavorite(ref.read(widget.entityProvider).entity);
    });
  }

  animation() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    sizeAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween(begin: 30, end: 50), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 50, end: 30), weight: 50),
    ]).animate(animationController!);
  }

  @override
  void didChangeDependencies() {
    refPlayProvider = ref.read(widget.playProvider);
    refEntityProvider = ref.read(widget.entityProvider);
    refColorProvider = ref.read(colorProvider);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
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
              const SizedBox(
                height: 10,
              ),
              artwork(width: w),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                height: 40,
                child: Marquee(
                  key: _refreshKey,
                  startPadding: 50,
                  text: (ref.read(widget.playProvider).tag.title != null &&
                          ref.read(widget.playProvider).tag.title != "")
                      ? ref.read(widget.playProvider).tag.title
                      : FileManager.basename(
                          ref.read(widget.entityProvider).entity ?? "Unknown"),
                  style: TextStyle(
                    fontSize: 25,
                    color: ref.watch(colorProvider).textColor,
                  ),
                  blankSpace: w,
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
                height: 250,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    ref
                                        .read(widget.playProvider)
                                        .decreaseSpeed();
                                  },
                                  icon: Icon(
                                    Icons.remove,
                                    color: ref.read(colorProvider).textColor,
                                    size: 30,
                                  )),
                              GestureDetector(
                                onTap: () {
                                  ref.read(widget.playProvider).resetSpeed();
                                },
                                child: Text(
                                  "${ref.watch(widget.playProvider).speed.toStringAsPrecision(ref.watch(widget.playProvider).speed >= 1 ? 2 : 1)}x",
                                  style: TextStyle(
                                      color: ref.read(colorProvider).textColor,
                                      fontSize: 20),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    ref
                                        .read(widget.playProvider)
                                        .increaseSpeed();
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: ref.read(colorProvider).textColor,
                                    size: 30,
                                  ))
                            ],
                          ),
                          AnimatedBuilder(
                            animation: animationController!,
                            builder: ((context, child) {
                              return IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    animationController!.reset();
                                    animationController!.forward();
                                    ref
                                            .watch(widget.favoriteProvider)
                                            .isFavorite
                                        ? ref
                                            .read(widget.favoriteProvider)
                                            .remove(ref
                                                .read(widget.entityProvider)
                                                .entity)
                                        : ref.read(widget.favoriteProvider).add(
                                            ref
                                                .read(widget.entityProvider)
                                                .entity);
                                  },
                                  icon: Icon(
                                    Icons.favorite,
                                    color: ref
                                            .watch(widget.favoriteProvider)
                                            .isFavorite
                                        ? Colors.red
                                        : ref.read(colorProvider).textColor,
                                    size: sizeAnimation!.value,
                                  ));
                            }),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      min: 0,
                      max: 100,
                      value: refPlayProvider.sliderValue,
                      thumbColor: Colors.blueGrey,
                      activeColor: ref.watch(colorProvider).textColor,
                      onChanged: (val) {
                        value = val;
                        ref.read(widget.playProvider).seek(value);
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
                              .seekBy(const Duration(seconds: -5)),
                          icon: Icon(
                            Icons.replay_5_rounded,
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
                              } else {
                                myProvider.play(
                                    entity: refEntityProvider.entity,
                                    next: forward,
                                    prev: rewind);
                                ref
                                    .read(widget.playProvider)
                                    .setTotalDuration();
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
                              .seekBy(const Duration(seconds: 5)),
                          icon: Icon(
                            Icons.forward_5_rounded,
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
              child: Hero(
                  tag: ref.watch(widget.playProvider).artwork.toString(),
                  child: Image.memory(ref.watch(widget.playProvider).artwork!)),
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
    _refreshKey = UniqueKey();
    FileSystemEntity? currentEntity = refEntityProvider.entity;
    if (currentEntity != entity) {
      refEntityProvider.setEntity(entity);
      await refPlayProvider.retrieveMetadata(entity);
      refPlayProvider.setPlaylist(entities);
      refPlayProvider.setPIndex(index);
      await ref.read(widget.favoriteProvider).checkFavorite(entity);
      setColor();
    }
    await refPlayProvider.play(entity: entity, next: forward, prev: rewind);
    refPlayProvider.setTotalDuration();
  }

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
