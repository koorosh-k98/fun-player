import 'dart:io';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:player/play_screen.dart';

class HomePage extends StatefulWidget {
  static const id = 'home_screen';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FileManagerController controller = FileManagerController();

  Widget title = const Text("");

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
    setState(() {
      title = ValueListenableBuilder<String>(
          valueListenable: controller.titleNotifier,
          builder: (context, title, _) {
            return Text(title);
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ControlBackButton(
      controller: controller,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => createFolder(context),
                icon: const Icon(Icons.create_new_folder_outlined),
              ),
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
          body: Container(
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
                          onTap: () async {
                            if (FileManager.isDirectory(entity)) {
                              // open the folder
                              controller.openDirectory(entity);

                              // delete a folder
                              // await entity.delete(recursive: true);

                              // rename a folder
                              // await entity.rename("newPath");

                              // Check weather folder exists
                              // entity.exists();

                              // get date of file
                              // DateTime date = (await entity.stat()).modified;
                            } else {
                              // showFlexibleBottomSheet(
                              //   // minHeight: 0.3,
                              //   initHeight: 0.3,
                              //   maxHeight: 1,
                              //   isDismissible: true,
                              //   isExpand: true,
                              //   isCollapsible: true,
                              //   isModal: true,
                              //   context: context,
                              //   builder: (
                              //     BuildContext context,
                              //     ScrollController scrollController,
                              //     double bottomSheetOffset,
                              //   ) {
                              //     return Material(
                              //       child: Container(
                              //         child: ListView(
                              //           controller: scrollController,
                              //           children: [
                              //             Text(FileManager.basename(entity)),
                              //           ],
                              //         ),
                              //       ),
                              //     );
                              //     // return PlayScreen(entity: entity);
                              //   },
                              //   anchors: [0, 0.5, 1],
                              //   isSafeArea: true,
                              // );

                              showMaterialModalBottomSheet(
                                enableDrag: true,
                                // bounce: true,
                                isDismissible: false,
                                // expand: true,
                                context: context,
                                builder: (context) => Container(
                                  height: 200,
                                  child: Text(
                                    FileManager.basename(entity),
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                              );
                              // Navigator.of(context)
                              //     .push(MaterialPageRoute(builder: (context) {
                              //   return PlayScreen(entity: entity);
                              // }));
                            }

                            // delete a file
                            // await entity.delete();

                            // rename a file
                            // await entity.rename("newPath");

                            // Check weather file exists
                            // entity.exists();

                            // get date of file
                            // DateTime date = (await entity.stat()).modified;

                            // get the size of the file
                            // int size = (await entity.stat()).size;
                          }),
                    );
                  },
                );
              },
            ),
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

  createFolder(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController folderName = TextEditingController();
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    controller: folderName,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Create Folder
                      await FileManager.createFolder(
                          controller.getCurrentPath, folderName.text);
                      // Open Created Folder
                      controller.setCurrentPath =
                          "${controller.getCurrentPath}/${folderName.text}";
                    } catch (e) {
                      print("Catched error");
                    }

                    Navigator.pop(context);
                  },
                  child: const Text('Create Folder'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
