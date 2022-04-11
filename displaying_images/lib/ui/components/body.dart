import 'package:displaying_images/displaying_images.dart';
import 'package:displaying_images/logic/controllers/main_controller.dart';
import 'package:displaying_images/logic/controllers/folders_controller.dart';
import 'package:displaying_images/logic/controllers/images_controller.dart';
import 'package:displaying_images/logic/helper_functions.dart';
import 'package:displaying_images/ui/components/files_grid_view.dart';
import 'package:displaying_images/ui/components/folders_selected_menu.dart';
import 'package:displaying_images/ui/components/images_selected_menu.dart';
import 'package:displaying_images/ui/components/main_menu.dart';
import 'package:displaying_images/ui/components/path_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class Body extends StatefulWidget {
  final GlobalKey<AnimatedFloatingButtonState> animatedButtonKey;
  const Body({Key? key, required this.animatedButtonKey}) : super(key: key);

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  final DisplayingImagesController _controller = Get.find();
  final ImagesController _imagesController = Get.find();
  final FoldersController _foldersController = Get.find();
  late final ScrollController _filesScrollController;
  BuildContext? dialogContext;

  TextEditingController folderName = TextEditingController();

  @override
  void initState() {
    _filesScrollController = ScrollController();

    _controller.showStateDialog = () {
      dialogContext = context;
      showDialog(
          context: dialogContext!,
          builder: (_) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Obx(() {
                  var dialogState = _controller.dialogState.value;
                  if (dialogState.loading) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("Wait a sec this could take some time ...")
                      ],
                    );
                  }

                  if (dialogState.error.isNotEmpty) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_translateErrorCodes(dialogState.error)),
                        const SizedBox(
                          height: 10.0,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              if (dialogContext != null) {
                                Get.back();
                                dialogContext = null;
                              }
                            },
                            child: const Text("Okay"))
                      ],
                    );
                  }

                  if (dialogState.isDone) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(dialogState.doneMessage),
                        const SizedBox(
                          height: 10.0,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              if (dialogContext != null) {
                                Get.back();
                                dialogContext = null;
                              }
                              widget.animatedButtonKey.currentState
                                  ?.cancelButton();
                            },
                            child: const Text("Done"))
                      ],
                    );
                  } else {
                    return Container();
                  }
                }),
              ),
            );
          });
    };

    _controller.loadFiles();

    _filesScrollController.addListener(() {
      // if (_filesScrollController.position.pixels == _filesScrollController.position.maxScrollExtent) {
      //   // _controller.loadMoreFiles();
      //   print("koko load more");
      // }
      if (_filesScrollController.offset >=
              _filesScrollController.position.maxScrollExtent &&
          !_filesScrollController.position.outOfRange) {
        print("koko load more");
        _controller.loadMoreFiles();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _foldersController.dispose();
    _imagesController.dispose();
    _filesScrollController.dispose();
    folderName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 40.0, left: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (exctractCurrentFolderName(_controller.currentPath.value) !=
                        "/" &&
                    exctractCurrentFolderName(_controller.currentPath.value) !=
                        "") {
                  return IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // goBack();
                    },
                  );
                } else {
                  return Container(
                    height: 72.0,
                    width: 72.0,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage("assets/images/lock_icon.png"))),
                  );
                }
              }),
              Expanded(
                child: Obx(() => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, ${_controller.viewState.value.user.name.capitalizeFirstLetter()}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: nameTextStyle,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          "Protect your files",
                          style: subTextStyle,
                        ),
                      ],
                    )),
              ),
              Obx(() {
                var selectionViewState = _controller.selectionViewState.value;
                if (selectionViewState.isSelectingImages) {
                  return ImagesSelectedMenu(
                    cancelSelection: () {
                      _controller.cancelSelecting();
                    },
                    decryptImages: () {
                      _imagesController.decryptImagesToGallery();
                    },
                    deleteImages: () {
                      _controller.deleteFiles();
                    },
                    shareImages: () {
                      _imagesController.shareImages();
                    },
                  );
                }

                if (selectionViewState.isSelectingFolders) {
                  return FolderSelectedMenu(
                      deleteAllFolders: () {
                        _controller.deleteFiles();
                      },
                      cancelSelecting: () {});
                }

                return MainMenu(
                  goToAboutUs: () {},
                );
              })
              // Obx(() => buildMenuesRow())
            ],
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  topLeft: Radius.circular(30.0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PathTextWidget(path: _controller.currentPath.value),
              Obx(() {
                var viewState = _controller.viewState.value;

                if (viewState.loading) {
                  return Container(
                    margin: EdgeInsets.only(top: screenHeight / 5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (viewState.files.isNotEmpty) {
                  return Expanded(
                      child: FilesGridView(
                    images: viewState.files,
                    scrollController: _filesScrollController,
                  ));
                } else {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(
                          height: 50.0,
                        ),
                        Align(child: Text("No Encrypted Images Yet .")),
                        SizedBox(
                          height: 50.0,
                        ),
                      ]);
                }
              }),
              Obx(() {
                var viewState = _controller.viewState.value;

                if (viewState.loadingMore) {
                  return const SizedBox(
                    height: 50.0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Container();
                }
              })
            ],
          ),
        ))
      ],
    );
  }

  createNewFolder() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Create New Folder"),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: folderName,
                  decoration: const InputDecoration(
                    hintText: "Folder Name",
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _foldersController.addFolder(folderName.text);
                        Navigator.pop(context);
                      },
                      child: const Text("Create"),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  String _translateErrorCodes(String code) {
    print(code);
    if (code == DisplayImagesErrorCodes.couldNotDecryptImages.toString()) {
      return "Could not decrypt images";
    } else if (code == DisplayImagesErrorCodes.couldNotDeleteFiles.toString()) {
      return "Could not delete files";
    } else if (code == DisplayImagesErrorCodes.failedToShareImages.toString()) {
      return "Could not share images";
    } else if (code ==
        DisplayImagesErrorCodes.exceededMaxDecryptNum.toString()) {
      return "Exceeded max decrypt number";
    } else if (code == DisplayImagesErrorCodes.couldNotDeleteFiles.toString()) {
      return "Could not delete files";
    } else if (code ==
        DisplayImagesErrorCodes.failedToImportImages.toString()) {
      return "Failed to import images";
    } else if (code ==
        DisplayImagesErrorCodes.fileNameAlreadyExists.toString()) {
      return "This file is here already";
    } else {
      throw "Not found error code";
    }
  }
}
