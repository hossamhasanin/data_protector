import 'dart:io';
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:base/base.dart';
import 'package:displaying_images/displaying_images.dart';
import 'package:displaying_images/logic/controllers/main_controller.dart';
import 'package:displaying_images/logic/controllers/folders_controller.dart';
import 'package:displaying_images/logic/controllers/images_controller.dart';
import 'package:displaying_images/logic/helper_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wifi_p2p/device.dart';
import 'package:wifi_p2p/wifi_p2p.dart';

import 'files_grid_view.dart';
import 'folders_selected_menu.dart';
import 'images_selected_menu.dart';
import 'main_menu.dart';
import 'path_text_widget.dart';

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
  final RefreshController _refreshController = RefreshController();
  BuildContext? dialogContext;

  TextEditingController folderName = TextEditingController();
  List<Device> devices = [];

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
                        Text(translateErrorCodes(dialogState.error)),
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

    _imagesController.showSelectShareMethodeDialog = () {
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text("Share via"),
                  leading: Icon(Icons.share),
                ),
                ListTile(
                  title: const Text("Share images encrypted"),
                  leading: const Icon(Icons.share),
                  onTap: () {
                    _imagesController.shareImages();
                    Get.back();
                  },
                ),
                ListTile(
                  title: const Text("Share images decrypted"),
                  leading: const Icon(Icons.share),
                  onTap: () async {
                    Get.back();
                    _imagesController.getSelectedImages((images) {
                      _controller.cancelSelecting();
                      Get.toNamed(sendImagesScreen, arguments: images);
                    });
                  },
                ),
              ],
            );
          });
    };

    _imagesController.showSelectReceivingMethodeDialog = () {
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text("Receive via"),
                  leading: Icon(Icons.share),
                ),
                ListTile(
                  title: const Text("Receive images encrypted"),
                  leading: const Icon(Icons.share),
                  onTap: () async {
                    Get.back();
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(allowMultiple: true);

                    if (result != null) {
                      List<File> files =
                          result.paths.map((path) => File(path!)).toList();
                      _imagesController.importZipedImages(files);
                    }
                  },
                ),
                ListTile(
                  title: const Text("Receive images decrypted"),
                  leading: const Icon(Icons.share),
                  onTap: () {
                    Get.back();
                    Get.toNamed(receiveImagesScreen);
                  },
                ),
              ],
            );
          });
    };

    _imagesController.showEncryptionStateDialog = () {
      dialogContext = context;
      showProgressDialog(dialogContext!, _imagesController.encryptionState,
          translateErrorCodes,
          onDoneAction: () {}, closeDialog: () {
        if (dialogContext != null) {
          Get.back();
          dialogContext = null;
        }
      });
    };

    _controller.showConfirmDialog = (message) async {
      bool result = false;
      await Get.defaultDialog(
          content: Text(message),
          textConfirm: "Yes",
          textCancel: "No",
          onConfirm: () {
            result = true;
            Get.back();
          },
          onCancel: () {
            result = false;
            Get.back();
          });
      return result;
    };

    _controller.loadFiles();

    // _filesScrollController.addListener(() {
    //   // if (_filesScrollController.position.pixels == _filesScrollController.position.maxScrollExtent) {
    //   //   // _controller.loadMoreFiles();
    //   //   print("koko load more");
    //   // }
    //   if (_filesScrollController.offset >=
    //           _filesScrollController.position.maxScrollExtent &&
    //       !_filesScrollController.position.outOfRange) {
    //     print("koko load more");
    //     _controller.loadMoreFiles();
    //   }
    // });

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
                      _foldersController.goBack();
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
                    shareImages: () async {
                      _imagesController.showSelectShareMethodeDialog();
                    },
                  );
                }

                if (selectionViewState.isSelectingFolders) {
                  return FolderSelectedMenu(deleteAllFolders: () {
                    _controller.deleteFiles();
                  }, cancelSelecting: () {
                    _controller.cancelSelecting();
                  });
                }

                return MainMenu(
                  goToAboutUs: () async {},
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
              Obx(() {
                return PathTextWidget(path: _controller.currentPath.value);
              }),
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
                      child: SmartRefresher(
                    enablePullDown: false,
                    enablePullUp: !viewState.noMoreData,
                    controller: _refreshController,
                    onLoading: () {
                      print("koko load more");
                      _controller.loadMoreFiles();
                      _refreshController.loadComplete();
                    },
                    child: FilesGridView(
                      images: viewState.files,
                      scrollController: _filesScrollController,
                    ),
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
              // Obx(() {
              //   var viewState = _controller.viewState.value;

              //   if (viewState.loadingMore) {
              //     return const SizedBox(
              //       height: 50.0,
              //       child: Center(
              //         child: CircularProgressIndicator(),
              //       ),
              //     );
              //   } else {
              //     return Container();
              //   }
              // })
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
                        folderName.text = "";
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
}
