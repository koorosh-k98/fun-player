import 'dart:io';

import 'package:audiotagger/audiotagger.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:player/play_music_provider.dart';
import 'package:player/play_screen.dart';
import 'package:player/title_provider.dart';
import 'entity_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  static const id = 'home_screen';

  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final FileManagerController controller = FileManagerController();

  Widget title = const Text("");
  List playlist = [];
  int pIndex = 0;
  List entities = [];

  final playProvider = ChangeNotifierProvider((_) => PlayMusicProvider());
  final entityProvider = ChangeNotifierProvider((_) => EntityProvider());
  final titleProvider = ChangeNotifierProvider((_) => TitleProvider());
  final tagger = Audiotagger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getTitle();
    });
  }

  getTitle() async {
    String title;
    if (ref.read(titleProvider).title == null) {
      List storages = await FileManager.getStorageList();
      title = FileManager.basename(storages.first);
    } else {
      title = controller.getCurrentPath.split("/").last;
    }
    ref.read(titleProvider).setTitle = title;
  }

  final snackBar = SnackBar(
    content: const Text('Unsupported file'),
    action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          //to dismiss the Snackbar I deliberately left it empty
        }),
  );

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width * 0.35;
    return ControlBackButton(
      controller: controller,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => sort(context),
                icon: const Icon(Icons.sort_rounded),
              ),
              IconButton(
                onPressed: () => selectStorage(context),
                icon: const Icon(Icons.sd_storage_rounded),
              )
            ],
            title: Consumer(builder: (context, ref, _) {
              if (ref.watch(titleProvider).title != null) {
                return Text(ref.read(titleProvider).title!);
              } else {
                return const Text("Music Player");
              }
            }),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await controller.goToParentDirectory();
                getTitle();
              },
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(5),
                  child: FileManager(
                    controller: controller,
                    builder: (context, snapshot) {
                      entities = [];
                      entities = snapshot
                          .where((e) =>
                              (FileManager.isDirectory(e) ||
                                  FileManager.getFileExtension(e) == "mp3") ||
                              FileManager.getFileExtension(e) == "m4a")
                          .toList();

                      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      // ref.read(playProvider).setLength(entities.length);
                      // ref.read(playProvider).retrieveArtworks(entities);
                      // });
                      return ListView.builder(
                        itemCount: entities.length,
                        itemBuilder: (context, index) {
                          FileSystemEntity entity = entities[index];
                          return Card(
                            child: ListTile(
                                leading: (FileManager.isFile(entity)
                                    ? Container(
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue),
                                        width: 55,
                                        height: 55,
                                        child: FutureBuilder(
                                          future: tagger.readArtwork(
                                              path: entity.path),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Image.memory(
                                                    snapshot.data!),
                                              );
                                            } else if (snapshot.hasError) {
                                              print(
                                                  "errorrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr${snapshot.error}");
                                            } else {
                                              return Center(
                                                child: Text(
                                                  FileManager.basename(entity)
                                                      .substring(0, 1),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 33),
                                                ),
                                              );
                                            }
                                            return Container();
                                          },
                                        )
                                        // Consumer(
                                        //     builder: (context, ref, _) {
                                        //   if (ref
                                        //       .watch(playProvider)
                                        //       .artworks
                                        //       .isNotEmpty) {
                                        //     return (ref
                                        //                 .watch(playProvider)
                                        //                 .artworks[index] ==
                                        //             null)
                                        //         ? Center(
                                        //             child: Text(
                                        //               FileManager.basename(
                                        //                       entity)
                                        //                   .substring(0, 1),
                                        //               style: const TextStyle(
                                        //                   color: Colors.white,
                                        //                   fontSize: 33),
                                        //             ),
                                        //           )
                                        //         : ClipRRect(
                                        //             borderRadius:
                                        //                 BorderRadius.circular(
                                        //                     30),
                                        //             child: Image.memory(ref
                                        //                 .watch(playProvider)
                                        //                 .artworks[index]),
                                        //           );
                                        //   } else {
                                        //     return Container();
                                        //   }
                                        // }),
                                        )
                                    : const SizedBox(
                                        height: 50,
                                        child: Icon(
                                          Icons.folder,
                                          color: Colors.amber,
                                        ))),
                                title: Text(FileManager.basename(entity)),
                                subtitle: subtitle(entity),
                                onTap: () async {
                                  if (FileManager.isDirectory(entity)) {
                                    controller.openDirectory(entity);
                                    getTitle();
                                  } else {
                                    myPlay(index, entity, entities);
                                  }
                                }),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Consumer(builder: (context, ref, _) {
                if (ref.watch(entityProvider).entity != null) {
                  return GestureDetector(
                    onTap: () {
                      showMaterialModalBottomSheet(
                        enableDrag: true,
                        isDismissible: false,
                        context: context,
                        builder: (context) => PlayScreen(
                          entity: ref.read(entityProvider).entity,
                          artwork: ref.read(playProvider).artwork,
                          tag: ref.read(playProvider).tag,
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
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.blue),
                            width: 62,
                            height: 62,
                            child: Consumer(builder: (context, ref, _) {
                              return ref.watch(playProvider).artwork == null
                                  ? Center(
                                      child: Text(
                                        FileManager.basename(
                                                ref.read(entityProvider).entity)
                                            .substring(0, 1),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 33),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.memory(
                                          ref.read(playProvider).artwork!),
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
                                    text: FileManager.basename(
                                        ref.read(entityProvider).entity),
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
                                    velocity: 30,
                                    blankSpace: w,
                                    fadingEdgeStartFraction: 0.2,
                                    fadingEdgeEndFraction: 0.2,
                                  ),
                                ),
                                SizedBox(
                                  height: 25,
                                  width: w,
                                  child: Consumer(builder: (context, ref, _) {
                                    return Text(
                                      ref.watch(playProvider).tag?.artist ??
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              IconButton(
                                  onPressed: rewind,
                                  icon: const Icon(
                                    Icons.fast_rewind,
                                    size: 30,
                                    color: Colors.white,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    final myProvider = ref.read(playProvider);

                                    if (myProvider.isPlaying) {
                                      myProvider.pause();
                                    } else {
                                      myProvider.play(
                                          entity:
                                              ref.read(entityProvider).entity);
                                    }
                                  },
                                  icon: Icon(
                                    ref.watch(playProvider).isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    size: 35,
                                    color: Colors.white,
                                  )),
                              IconButton(
                                  onPressed: forward,
                                  icon: const Icon(
                                    Icons.fast_forward_sharp,
                                    size: 30,
                                    color: Colors.white,
                                  )),
                              const SizedBox(
                                width: 15,
                              )
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
          )),
    );
  }

  forward() {
    List playlist = ref.read(playProvider).playlist;
    int index = ref.read(playProvider).pIndex;
    if (index < playlist.length - 1) {
      index++;
    }
    myPlay(index, playlist[index], playlist);
  }

  rewind() {
    List playlist = ref.read(playProvider).playlist;
    int index = ref.read(playProvider).pIndex;
    if (index > 0) {
      index--;
    }
    myPlay(index, playlist[index], playlist);
  }

  void myPlay(int index, FileSystemEntity entity, List entities) {
    FileSystemEntity? currentEntity = ref.read(entityProvider).entity;
    if (currentEntity != entity) {
      ref.read(entityProvider).setEntity(entity);
      ref.read(playProvider).getMetadata(entity);
      ref.read(playProvider).setPlaylist(entities);
      ref.read(playProvider).setPIndex(index);
    }
    ref.read(playProvider).play(entity: entity);
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

  selectStorage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: FileManager.getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: storageList
                        .map((e) => ListTile(
                              title: Text(
                                FileManager.basename(e),
                              ),
                              onTap: () {
                                controller.openDirectory(e);
                                getTitle();
                                Navigator.pop(context);
                              },
                            ))
                        .toList()),
              );
            }
            return const Dialog(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  sort(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  title: const Text("Name"),
                  onTap: () {
                    controller.sortBy(SortBy.name);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("Size"),
                  onTap: () {
                    controller.sortBy(SortBy.size);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("Date"),
                  onTap: () {
                    controller.sortBy(SortBy.date);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("type"),
                  onTap: () {
                    controller.sortBy(SortBy.type);
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
