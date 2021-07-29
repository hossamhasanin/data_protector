import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:base/Constants.dart';
import 'package:data_protector/auth/widgets/LoginPage.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_bloc.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_events.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_states.dart';
import 'package:data_protector/encryptImages/widgets/FolderCard.dart';
import 'package:data_protector/encryptImages/widgets/show_full_image.dart';
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:data_protector/ui/UiHelpers.dart';
import 'package:data_protector/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:data_protector/util/helper_functions.dart';
import 'package:data_protector/aboutus/AboutUsWidget.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'ImageCard.dart';

class EncryptedImagesWidget extends StatefulWidget {
  @override
  _EncryptedImagesWidgetState createState() => _EncryptedImagesWidgetState();
}

class _EncryptedImagesWidgetState extends State<EncryptedImagesWidget>
    with TickerProviderStateMixin {
  final EncryptImagesBloc bloc = EncryptImagesBloc(useCase: Get.find());
  late ScrollController controller;
  late AnimationController _floatingButtonController;
  late TextEditingController folderName;

  static const List<IconData> icons = const [
    Icons.create_new_folder,
    Icons.add_photo_alternate_outlined,
    Icons.file_download
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = ScrollController();
    _floatingButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    folderName = TextEditingController();

    watchCreateFolderState();
    watchDecryptState();
    watchLogOutState();
    watchDeleteFolderState();
    watchShareState();
    watchImportFilesState();
    watchDeleteFilesState();
    watchEncryptState();

    bloc.errorWhileDisplayingImage.listen((isError) {
      if (isError) {
        Get.snackbar(
            "Error !", "Some files couldn't get decrypted by the current key",
            colorText: Colors.white, backgroundColor: Colors.red);
      }
    });

    bloc.add(GetStoredFiles(path: "/", clearTheList: false));
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).accentColor;

    return Scaffold(
      floatingActionButton: animatedFloatingActionButtons(
          _floatingButtonController, icons, backgroundColor, foregroundColor, [
        // create folder
        () {
          showCreateNewFolderDialog();
        },
        // encrypt image
        () {
          loadAssets();
        },
        // import encrypted files to the app
        () {
          bloc.add(ImportEncFiles());
        }
      ]),
      backgroundColor: Colors.blue,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 40.0, left: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  if (bloc.dir.value != "/") {
                    return IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        var paths = bloc.dir.value.split("/").toList();
                        paths.removeLast();
                        bloc.dir.value =
                            paths.last == "files" ? "/" : paths.join("/");
                        bloc.add(GetStoredFiles(
                            path: bloc.dir.value, clearTheList: true));
                      },
                    );
                  } else {
                    return Container(
                      height: 72.0,
                      width: 72.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image:
                                  AssetImage("assets/images/lock_icon.png"))),
                    );
                  }
                }),
                Expanded(
                  child: Obx(() => Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, ${bloc.user.value.name.capitalizeFirstLetter()}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: nameTextStyle,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Protect your files",
                            style: subTextStyle,
                          ),
                        ],
                      )),
                ),
                Obx(() => buildMenuesRow())
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Expanded(
              child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0))),
            child: mainContents(),
          ))
        ],
      ),
    );
  }

  Widget buildMenuesRow() {
    return Column(
      children: [
        Row(
          children: bloc.isImageSelecting.value
              ? [
                  IconButton(
                      icon: Icon(
                        Icons.lock_open,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // decrypt the selected images
                        bloc.add(DecryptImages());
                        bloc.isImageSelecting.value = false;
                      }),
                  IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        bloc.isImageSelecting.value = false;
                        bloc.selectedImages.value = List.empty();
                      })
                ]
              : bloc.isFolderSelecting.value
                  ? [
                      IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            bloc.add(DeleteFolders(
                                folders: bloc.selectedFolder.value));
                            bloc.isFolderSelecting.value = false;
                            bloc.selectedFolder.value = List.empty();
                          }),
                      IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            bloc.isFolderSelecting.value = false;
                            bloc.selectedFolder.value = List.empty();
                          })
                    ]
                  : [
                      PopupMenuButton<String>(
                          onSelected: (String choice) {
                            switch (choice) {
                              case 'Logout':
                                bloc.add(LogOut());
                                break;
                              case 'About us':
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => AboutUs()));
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return {'Logout', 'About us'}.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          )),
                    ],
        ),
        bloc.isImageSelecting.value
            ? Row(
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        AwesomeDialog(
                            context: context,
                            title: "Note !",
                            dialogType: DialogType.INFO,
                            desc:
                                "Now you will share the encrypted virsion of your images"
                                " to be able to decrypt them on the oher device please use"
                                " the app with the same email that has the same encryption"
                                " key to be able to open them ,"
                                "  you will find the files has extension "
                                "(.$ENC_EXTENSION) at the end of the file",
                            btnOkColor: Colors.green,
                            btnOkOnPress: () {
                              bloc.add(ShareImages());
                              bloc.isImageSelecting.value = false;
                            },
                            btnCancelColor: Colors.red,
                            btnCancelOnPress: () {})
                          ..show();
                      }),
                  IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        AwesomeDialog(
                            context: context,
                            title: "Warning !",
                            dialogType: DialogType.WARNING,
                            desc: "Be noticed that if you deleted those images"
                                " it will be deleted permenantly so are you sure you want so ?",
                            btnOkColor: Colors.green,
                            btnCancelColor: Colors.red,
                            btnOkOnPress: () {
                              bloc.add(DeleteFiles());
                              bloc.isImageSelecting.value = false;
                            },
                            btnCancelOnPress: () {})
                          ..show();
                      })
                ],
              )
            : Container()
      ],
    );
  }

  Widget mainContents() {
    double screeHeight = MediaQuery.of(context).size.height;
    return Obx(() {
      var state = bloc.getImagesState.value;
      print("koko state is >" + state.toString());
      if (state is GotImages) {
        if (state.images.isNotEmpty) {
          return buildGridView(state);
        } else {
          return Container(
            width: double.infinity,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              pathNameWidget(),
              Spacer(),
              Align(child: Text("No Encrypted Images Yet .")),
              Spacer()
            ]),
          );
        }
      } else if (state is GettingImagesFailed) {
        return Container(
          margin: EdgeInsets.only(top: screeHeight / 5),
          child: Center(
            child: Text(state.error),
          ),
        );
      } else if (state is GettingImages) {
        return Container(
          margin: EdgeInsets.only(top: screeHeight / 5),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        return Container();
      }
    });
  }

  Widget pathNameWidget() {
    return Text(
        "Your files : " + exctractCurrentFolderName(bloc.dir.value) + "/",
        style: titleTextStyle);
  }

  Widget buildGridView(GotImages state) {
    var isFolderSelecting = bloc.isFolderSelecting;
    var isImageSelecting = bloc.isImageSelecting;

    print("koko select > " + isFolderSelecting.value.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pathNameWidget(),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0),
                  //semanticChildCount: state.images.length,
                  itemCount: state.images.length,
                  itemBuilder: (context, index) {
                    var file = state.images[index];
                    if (file.file.type == SavedFileType.FOLDER.index) {
                      print("paths > ${file.file.name} ,  ${file.file.path}");
                      //return buildFolderCard(file);
                      return FolderCard(
                        isFolderSelecting: isFolderSelecting,
                        isImageSelecting: isImageSelecting,
                        folder: file,
                        selectedFolder: bloc.selectedFolder,
                        onTap: () {
                          if (!bloc.isImageSelecting.value &&
                              !bloc.isFolderSelecting.value) {
                            bloc.add(GetStoredFiles(
                                path: file.file.path + "/" + file.file.name,
                                clearTheList: true));
                          } else {
                            if (!bloc.isImageSelecting.value) {
                              if (!bloc.selectedFolder.contains(file)) {
                                bloc.selectedFolder.add(file);
                              } else {
                                bloc.selectedFolder.remove(file);
                                if (bloc.selectedFolder.isEmpty) {
                                  bloc.isFolderSelecting.value = false;
                                }
                              }
                            }
                          }
                        },
                        onLongPress: () {
                          if (!bloc.isFolderSelecting.value &&
                              !bloc.isImageSelecting.value) {
                            bloc.isFolderSelecting.value = true;
                            bloc.selectedFolder.add(file);
                          }
                        },
                      );
                    } else if (file.file.type == SavedFileType.IMAGE.index) {
                      //return buildImageCard(file);
                      return ImageCard(
                          isFolderSelecting: isFolderSelecting,
                          isImageSelecting: isImageSelecting,
                          image: file,
                          selectedImages: bloc.selectedImages,
                          onLongPress: () {
                            if (!bloc.isFolderSelecting.value &&
                                !bloc.isImageSelecting.value) {
                              bloc.isImageSelecting.value = true;
                              bloc.selectedImages.add(file);
                            }
                          },
                          onTap: () {
                            if (bloc.isImageSelecting.value &&
                                !bloc.isFolderSelecting.value) {
                              if (!bloc.selectedImages.contains(file)) {
                                bloc.selectedImages.add(file);
                                print("koko add files > " +
                                    bloc.selectedImages.value.length
                                        .toString());
                              } else {
                                bloc.selectedImages.remove(file);
                                if (bloc.selectedImages.isEmpty) {
                                  bloc.isImageSelecting.value = false;
                                }
                              }
                            } else {
                              print("len > open photo name >" +
                                  file.thumbUint8list!.lengthInBytes
                                      .toString());
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowFullImage(
                                          image: file.uint8list!)));
                            }
                          });
                    } else {
                      throw Exception("No matched file type");
                    }
                  })),
        )
      ],
    );
  }

  Widget buildImageCard(FileWrapper image) {
    return GestureDetector(
        onLongPress: () {
          if (!bloc.isFolderSelecting.value && !bloc.isImageSelecting.value) {
            bloc.isImageSelecting.value = true;
            bloc.selectedImages.add(image);
          }
        },
        onTap: () {
          if (bloc.isImageSelecting.value && !bloc.isFolderSelecting.value) {
            if (!bloc.selectedImages.contains(image)) {
              bloc.selectedImages.add(image);
            } else {
              bloc.selectedImages.remove(image);
              if (bloc.selectedImages.isEmpty) {
                bloc.isImageSelecting.value = false;
              }
            }
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ShowFullImage(image: image.uint8list!)));
          }
        },
        child: Obx(() => Container(
              padding: bloc.selectedImages.contains(image)
                  ? EdgeInsets.all(5.0)
                  : null,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                color: bloc.selectedImages.contains(image) ? Colors.grey : null,
              ),
              child: bloc.isImageSelecting.value
                  ? containerImageCard(image.uint8list!)
                  : putImageInHero(
                      image.file.id, containerImageCard(image.uint8list!)),
            )));
  }

  Widget putImageInHero(String tag, Widget im) {
    return Hero(
      tag: tag,
      child: im,
    );
  }

  Widget containerImageCard(Uint8List im) {
    return Container(
        decoration: BoxDecoration(
      image: DecorationImage(image: MemoryImage(im), fit: BoxFit.cover),
      borderRadius: BorderRadius.circular(30.0),
    ));
  }

  Widget buildFolderCard(FileWrapper folder) {
    return InkWell(
      onTap: () {
        if (!bloc.isImageSelecting.value && !bloc.isFolderSelecting.value) {
          bloc.add(GetStoredFiles(
              path: folder.file.path + "/" + folder.file.name,
              clearTheList: true));
        } else {
          if (!bloc.isImageSelecting.value) {
            if (!bloc.selectedFolder.contains(folder)) {
              bloc.selectedFolder.add(folder);
            } else {
              bloc.selectedFolder.remove(folder);
              if (bloc.selectedFolder.isEmpty) {
                bloc.isFolderSelecting.value = false;
              }
            }
          }
        }
      },
      onLongPress: () {
        if (!bloc.isFolderSelecting.value && !bloc.isImageSelecting.value) {
          bloc.isFolderSelecting.value = true;
          bloc.selectedFolder.add(folder);
        }
      },
      child: Obx(
        () => Container(
            color: bloc.selectedFolder.contains(folder) ? Colors.grey : null,
            padding: bloc.selectedFolder.contains(folder)
                ? EdgeInsets.all(5.0)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder,
                  color: Colors.blueAccent,
                  size: 46.0,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  folder.file.name,
                  style: subTitleTextStyle,
                )
              ],
            )),
      ),
    );
  }

  watchCreateFolderState() {
    bloc.createNewFolderState.listen((state) {
      print("koko > " + state.toString());
      if (state is CreatingNewFolder) {
        Get.snackbar("Folders", "Creating new folder");
      } else if (state is CreateNewFolderDone) {
        Get.snackbar("Folders", "Folder created successfully");
      } else if (state is CreateNewFolderFailed) {
        Get.defaultDialog(
            title: "Folders Error",
            content: Padding(
                padding: EdgeInsets.all(20.0), child: Text(state.error)),
            backgroundColor: Colors.white);
        printError(info: state.error);
      }
    });
  }

  watchShareState() {
    bloc.shareImagesState.listen((state) {
      print("koko > " + state.toString());
      if (state is SharingImage) {
        Get.snackbar("Sharing", "opening the share ...");
      } else if (state is SharedImagesSuccessFully) {
        Get.snackbar("Done !", "Images shared successfully");
      } else if (state is ShareImagesFailed) {
        Get.defaultDialog(
            title: "Error !!",
            content: Padding(
                padding: EdgeInsets.all(20.0), child: Text(state.error)),
            backgroundColor: Colors.white);
      }
    });
  }

  watchImportFilesState() {
    bloc.importEncFilesState.listen((state) {
      print("koko > " + state.toString());
      if (state is ImportingEncFiles) {
        Get.snackbar("Opening", "Open file system");
      } else if (state is ImportedEncFilesSuccessFully) {
        Get.snackbar("New files !", "Imported the new files successfully");
      } else if (state is ImportEncFilesFailed) {
        Get.defaultDialog(
            title: "Folders Error",
            content: Padding(
                padding: EdgeInsets.all(20.0), child: Text(state.error)),
            backgroundColor: Colors.white);
        printError(info: state.error);
      }
    });
  }

  watchEncryptState() {
    bloc.encryptState.listen((state) {
      print("came here");
      if (state is EncryptDone) {
        Navigator.pop(context);
        AwesomeDialog(
            context: context,
            title: "Hey !",
            dialogType: DialogType.INFO,
            desc:
                "Be aware that the original images hasn't been deleted from the gallery "
                "so you should go and delete those images from your gallery first , "
                "and dont worry the app now protect those images by encrypting them for you ")
          ..show();
      } else if (state is EncryptFailed) {
        Navigator.pop(context);
        AwesomeDialog(
            context: context,
            dialogType: DialogType.WARNING,
            animType: AnimType.SCALE,
            title: "Failed !",
            desc: state.error)
          ..show();
      } else if (state is Encrypting) {
        showCustomDialog(
            context: context,
            title: "Wait a bit ...",
            children: [Center(child: CircularProgressIndicator())],
            dissmissable: false);
      }
    });
  }

  watchDecryptState() {
    bloc.decryptState.listen((state) {
      print("koko > " + state.toString());
      if (state is Decrypting) {
        Get.snackbar("Decryption", "Decrypting images");
      } else if (state is DecryptDone) {
        Get.snackbar("Decryption", "Decryption worked successfully");
      } else if (state is DecryptFailed) {
        Get.snackbar("Decryption", "Error happened while Decrypting !");
        printError(info: state.error);
      }
    });
  }

  watchLogOutState() {
    bloc.signOutState.listen((state) {
      print("koko > " + state.toString());
      if (state is SignedOutSuccessFully) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      } else if (state is SignedOutFailed) {
        Get.snackbar("Auth", state.error);
        print("koko > " + state.error);
      }
    });
  }

  watchDeleteFolderState() {
    bloc.deletefolderState.listen((state) {
      print("koko > " + state.toString());
      if (state is DeletingFolder) {
        Get.snackbar("Delete Folders", "Deleting folders");
      } else if (state is DeleteFolderDone) {
        Get.snackbar("Delete Folders", "Deleted folders successfully");
      } else if (state is DeleteFolderFailed) {
        Get.snackbar("Delete Folders", "Error happened while Deleting !");
        printError(info: state.error);
      }
    });
  }

  watchDeleteFilesState() {
    bloc.deleteFilesState.listen((state) {
      print("koko > " + state.toString());
      if (state is DeletingFiles) {
        Get.snackbar("Wait", "Deleting those files now");
      } else if (state is DeleteFilesSuccessFully) {
        Get.snackbar("Done", "Deleted files successfully");
      } else if (state is DeleteFilesFailed) {
        Get.snackbar("Failes", "Error happened while Deleting !");
        printError(info: state.error);
      }
    });
  }

  showCreateNewFolderDialog() {
    showCustomDialog(context: context, title: "Create new folder", children: [
      TextField(
        decoration: InputDecoration(
            hintText: "Folder name ... ",
            labelText: "Folder name",
            hintStyle: TextStyle(color: Colors.grey)),
        controller: folderName,
      ),
      RaisedButton(
        color: Theme.of(context).primaryColor,
        child: Text(
          "Create",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          bloc.add(CreateNewFolder(name: folderName.text));
          folderName.clear();
          Navigator.pop(context);
        },
      )
    ]);
  }

  // Future<List<AssetEntity>> _pickAsset(PickType type,
  //     {List<AssetPathEntity>? pathList}) async {
  //   List<AssetEntity> imgList = await PhotoPicker.pickAsset(
  //     // BuildContext required
  //     context: context,
  //     provider: I18nProvider.english,
  //     pickType: type,
  //     thumbSize: THUMB_SIZE,
  //     maxSelected: MAX_SELECTED_IMAGES,
  //     photoPathList: pathList,
  //   );

  //   if (imgList == null || imgList.isEmpty) {
  //     print("no pick");
  //     return Future.value(null);
  //   } else {
  //     return imgList;
  //   }
  // }

  // Future<void> loadAssets() async {
  //   List<Uint8List> resultList = [];
  //   List<Uint8List> thumbtList = [];

  //   try {
  //     var assetPathList =
  //         await PhotoManager.getAssetPathList(type: RequestType.image);
  //     var picked =
  //         await _pickAsset(PickType.onlyImage, pathList: assetPathList);
  //     if (picked != null) {
  //       for (var image in picked) {
  //         var thumb = await image.thumbDataWithSize(64, 64);

  //         var origin = await image.originBytes;
  //         resultList.add(origin!);
  //         thumbtList.add(thumb!);
  //       }
  //       print("len > resultList " + resultList[0].lengthInBytes.toString());
  //       print("len > thums " + thumbtList[0].lengthInBytes.toString());

  //       bloc.add(EncryptImages(images: resultList, thumbs: thumbtList));
  //     }
  //   } on Exception catch (e) {
  //     bloc.add(PickingImagesError(error: e.toString()));
  //   }
  // }

  Future loadAssets() async {
    List<Uint8List> resultList = [];
    List<Uint8List> thumbtList = [];

    try {
      final List<AssetEntity>? picked = await AssetPicker.pickAssets(context,
          maxAssets: MAX_SELECTED_IMAGES,
          gridThumbSize: THUMB_SIZE,
          textDelegate: EnglishTextDelegate());
      if (picked != null) {
        for (var image in picked) {
          var thumb = await image.thumbDataWithSize(THUMB_SIZE, THUMB_SIZE);
          var origin = await image.originBytes;
          resultList.add(origin!);
          thumbtList.add(thumb!);
        }

        bloc.add(EncryptImages(images: resultList, thumbs: thumbtList));
      }
    } catch (e) {
      bloc.add(PickingImagesError(error: e.toString()));
    }
  }
}
