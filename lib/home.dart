import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:player/play_music.dart';
import 'package:player/play_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  static const id = 'home_screen';

  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final FileManagerController controller = FileManagerController();
  FileSystemEntity? _selectedEntity;

  Widget title = const Text("");

  final playProvider = ChangeNotifierProvider((_) => PlayMusic());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getTitle();
    });
  }

  final snackBar = SnackBar(
    content: const Text('Unsupported file'),
    action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          //to dismiss the Snackbar I deliberately left it empty
        }),
  );

  getTitle() async {
    title = ValueListenableBuilder<String>(
        valueListenable: controller.titleNotifier,
        builder: (context, title, _) {
          return Text(title);
        });
  }

  //to avoid going to the root directory
  remainInCurrentPath() {
    controller.setCurrentPath = controller.getCurrentPath;
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height -
        (_selectedEntity != null ? 205 : 100);
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
            title: title,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await controller.goToParentDirectory();
              },
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: h,
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
                                  ? const Icon(Icons.music_note)
                                  : const Icon(Icons.folder)),
                              title: Text(FileManager.basename(entity)),
                              subtitle: subtitle(entity),
                              onTap: () {
                                if (FileManager.isDirectory(entity)) {
                                  controller.openDirectory(entity);
                                } else {
                                  _selectedEntity = entity;
                                  showMaterialModalBottomSheet(
                                      enableDrag: true,
                                      // bounce: true,
                                      isDismissible: false,
                                      // expand: true,
                                      context: context,
                                      builder: (context) {
                                        _selectedEntity = entity;
                                        remainInCurrentPath();
                                        ref.read(playProvider).play();
                                        return PlayScreen(entity: entity);
                                      });
                                }
                              }),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_selectedEntity != null)
                GestureDetector(
                  onTap: () {
                    showMaterialModalBottomSheet(
                        enableDrag: true,
                        // bounce: true,
                        isDismissible: false,
                        // expand: true,
                        context: context,
                        builder: (context) =>
                            PlayScreen(entity: _selectedEntity));
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
                            FileManager.basename(_selectedEntity),
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                            softWrap: true,
                            overflow:
                                FileManager.basename(_selectedEntity).length >
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
                                  color: Colors.white70,
                                )),
                            IconButton(
                                onPressed: () {
                                  final myProvider = ref.read(playProvider);

                                  if (myProvider.isPlaying) {
                                    myProvider.pause();
                                  } else {
                                    myProvider.play();
                                  }
                                },
                                icon: Icon(
                                  ref.watch(playProvider).isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 50,
                                  color: Colors.white70,
                                )),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.fast_forward_sharp,
                                  size: 50,
                                  color: Colors.white70,
                                )),
                            const SizedBox(
                              width: 15,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
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
