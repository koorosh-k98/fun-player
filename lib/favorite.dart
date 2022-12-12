import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:player/play_screen.dart';

class Favorite extends ConsumerStatefulWidget {
  const Favorite({
    required this.playProvider,
    required this.entityProvider,
    required this.favoriteProvider,
    Key? key,
  }) : super(key: key);

  final playProvider;
  final entityProvider;
  final favoriteProvider;

  @override
  ConsumerState<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends ConsumerState<Favorite> {
  Key _refreshKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width * 0.35;
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: body(w),
    );
  }

  body(double w) {
    if (ref.watch(widget.favoriteProvider).favorites.isEmpty) {
      return const Center(
        child: Text(
          "Favorites is empty",
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      List entities = ref.watch(widget.favoriteProvider).favorites;
      return Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(5),
              child: ListView.builder(
                itemCount: entities.length,
                itemBuilder: (context, index) {
                  FileSystemEntity entity = entities[index];
                  return Card(
                    child: ListTile(
                        leading: Container(
                          decoration:  BoxDecoration(
                              shape: BoxShape.circle, color: Theme.of(context).colorScheme.secondary),
                          width: 55,
                          height: 55,
                          child: FutureBuilder(
                            future: ref.read(widget.playProvider).retrieveArtwork(entity),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.memory(snapshot.data! as Uint8List),
                                );
                              } else if (!snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    FileManager.basename(entity)
                                        .substring(0, 1),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 33),
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                        title: Text(FileManager.basename(entity)),
                        subtitle: subtitle(entity),
                        trailing: IconButton(
                            onPressed: () {
                              ref.read(widget.favoriteProvider).remove(entity);
                            },
                            icon: const Icon(
                              Icons.heart_broken,
                              color: Colors.red,
                              size: 30,
                            )),
                        onTap: () {
                          var audioEntities = entities
                              .where((e) =>
                                  !FileManager.isDirectory(e) &&
                                  (FileManager.getFileExtension(e)
                                              .toLowerCase() ==
                                          "mp3" ||
                                      FileManager.getFileExtension(entity)
                                              .toLowerCase() ==
                                          "m4a" ||
                                      FileManager.getFileExtension(e)
                                              .toLowerCase() ==
                                          "wav"))
                              .toList();
                          index = audioEntities.indexOf(entity);
                          myPlay(index, entity, audioEntities);
                        }),
                  );
                },
              ),
            ),
          ),
          Consumer(builder: (context, ref, _) {
            if (ref.watch(widget.entityProvider).entity != null) {
              return GestureDetector(
                onTap: () {
                  showMaterialModalBottomSheet(
                    enableDrag: true,
                    isDismissible: false,
                    context: context,
                    builder: (context) => PlayScreen(
                      playProvider: widget.playProvider,
                      entityProvider: widget.entityProvider,
                      favoriteProvider: widget.favoriteProvider,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black54),
                  height: 90,
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Theme.of(context).colorScheme.secondary),
                        width: 62,
                        height: 62,
                        child: Consumer(builder: (context, ref, _) {
                          return ref.watch(widget.playProvider).artwork == null
                              ? Center(
                                  child: Text(
                                    FileManager.basename(ref
                                            .read(widget.entityProvider)
                                            .entity)
                                        .substring(0, 1),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 33),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Hero(
                                    tag: ref
                                        .watch(widget.playProvider)
                                        .artwork
                                        .toString(),
                                    child: Image.memory(
                                        ref.read(widget.playProvider).artwork!),
                                  ),
                                );
                        }),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 35,
                              width: w,
                              child: Marquee(
                                key: _refreshKey,
                                text: FileManager.basename(
                                    ref.read(widget.entityProvider).entity),
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                                velocity: 30,
                                blankSpace: w,
                                startPadding: 50,
                                fadingEdgeStartFraction: 0.2,
                                fadingEdgeEndFraction: 0.2,
                              ),
                            ),
                            SizedBox(
                              height: 25,
                              width: w,
                              child: Consumer(builder: (context, ref, _) {
                                return Text(
                                  ref.watch(widget.playProvider).tag?.artist ??
                                      "Unknown artist",
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: rewind,
                              icon: const Icon(
                                Icons.skip_previous,
                                size: 30,
                                color: Colors.white,
                              )),
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                final myProvider =
                                    ref.read(widget.playProvider);

                                if (myProvider.isPlaying) {
                                  myProvider.pause();
                                } else {
                                  myProvider.play(
                                      entity: ref
                                          .read(widget.entityProvider)
                                          .entity,
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
                                size: 45,
                                color: Colors.white,
                              )),
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: forward,
                              icon: const Icon(
                                Icons.skip_next,
                                size: 30,
                                color: Colors.white,
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          })
        ],
      );
    }
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

  void myPlay(int index, FileSystemEntity entity, List entities,
      [bool playMusic = true]) async {
    _refreshKey = UniqueKey();
    FileSystemEntity? currentEntity = ref.read(widget.entityProvider).entity;
    if (currentEntity != entity) {
      ref.read(widget.entityProvider).setEntity(entity);
      await ref.read(widget.playProvider).retrieveMetadata(entity);
      ref.read(widget.playProvider).setPlaylist(entities);
      ref.read(widget.playProvider).setPIndex(index);
    }
    if (playMusic) {
      await ref
          .read(widget.playProvider)
          .play(entity: entity, next: forward, prev: rewind);
      await ref.read(widget.playProvider).setTotalDuration();
    }
  }

  Widget subtitle(FileSystemEntity entity) {
    return FutureBuilder<FileStat>(
      future: entity.stat(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (entity is File) {
            int size = snapshot.data!.size;

            return Text(
              FileManager.formatBytes(size),
            );
          }
          return Text(
            "${snapshot.data!.modified}".substring(0, 10),
          );
        } else {
          return const Text("");
        }
      },
    );
  }
}
