import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  final playProvider = ChangeNotifierProvider((_) => PlayMusicProvider());
  final entityProvider = ChangeNotifierProvider((_) => EntityProvider());
  final titleProvider = ChangeNotifierProvider((_) => TitleProvider());

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
    // title = ValueListenableBuilder<String>(
    //     valueListenable: controller.titleNotifier,
    //     builder: (context, title, _) {
    //       return Text(title);
    //     });
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
    // double h = MediaQuery.of(context).size.height -
    //     (ref.read(entityProvider).entity != null ? 205 : 100);
    double w = MediaQuery.of(context).size.width * 0.30;
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
                  // height: h,
                  margin: const EdgeInsets.all(10),
                  child: FileManager(
                    controller: controller,
                    builder: (context, snapshot) {
                      List entities = [];
                      entities = snapshot
                          .where((e) =>
                              (FileManager.isDirectory(e) ||
                                  FileManager.getFileExtension(e) == "mp3") ||
                              FileManager.getFileExtension(e) == "m4a")
                          .toList();
                      return ListView.builder(
                        itemCount: entities.length,
                        itemBuilder: (context, index) {
                          FileSystemEntity entity = entities[index];
                          return Card(
                            child: ListTile(
                                leading: (FileManager.isFile(entity)
                                    ? const SizedBox(
                                        height: 50,
                                        child: Icon(Icons.music_note))
                                    : const SizedBox(
                                        height: 50, child: Icon(Icons.folder))),
                                title: Text(FileManager.basename(entity)),
                                subtitle: subtitle(entity),
                                onTap: () {
                                  if (FileManager.isDirectory(entity)) {
                                    controller.openDirectory(entity);
                                    getTitle();
                                  } else {
                                    ref.read(entityProvider).setEntity(entity);
                                    ref.read(playProvider).play(entity: entity);

                                    showMaterialModalBottomSheet(
                                        enableDrag: true,
                                        isDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return PlayScreen();
                                        });
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
                          builder: (context) => PlayScreen());
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green),
                      height: 100,
                      width: double.infinity,
                      child: Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.blue),
                            width: 60,
                            height: 60,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: w,
                            child: Text(
                              FileManager.basename(
                                  ref.read(entityProvider).entity),
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                              softWrap: true,
                              overflow: FileManager.basename(
                                              ref.read(entityProvider).entity)
                                          .length >
                                      35
                                  ? TextOverflow.ellipsis
                                  : TextOverflow.clip,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.fast_rewind,
                                    size: 50,
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
                                    size: 50,
                                    color: Colors.white,
                                  )),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.fast_forward_sharp,
                                    size: 50,
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
