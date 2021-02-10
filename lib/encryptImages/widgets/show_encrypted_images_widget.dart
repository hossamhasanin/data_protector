import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_protector/auth/widgets/LoginPage.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_bloc.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_events.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_states.dart';
import 'package:data_protector/encryptImages/widgets/show_full_image.dart';
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:data_protector/ui/UiHelpers.dart';
import 'package:data_protector/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:data_protector/util/helper_functions.dart';

class EncryptedImagesWidget extends StatefulWidget {
  @override
  _EncryptedImagesWidgetState createState() => _EncryptedImagesWidgetState();
}

class _EncryptedImagesWidgetState extends State<EncryptedImagesWidget>
    with TickerProviderStateMixin {
  final EncryptImagesBloc bloc = EncryptImagesBloc(useCase: Get.find());
  ScrollController controller;
  AnimationController _floatingButtonController;
  TextEditingController folderName;

  static const List<IconData> icons = const [
    Icons.create_new_folder,
    Icons.add_photo_alternate_outlined
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

    // Note : this part should have been seperate in its own function
    bloc.encryptState.listen((error) {
      print("came here");
      if (error == null) {
        AwesomeDialog(
            context: context,
            title: "Hey !",
            dialogType: DialogType.INFO,
            desc:
                "Be aware that the original images hasn't been deleted from the gallery "
                "so you should go and delete those images from your gallery first , "
                "and dont worry the app now protect those images by encrypting them for you ")
          ..show();
      } else {
        AwesomeDialog(
            context: context,
            dialogType: DialogType.WARNING,
            animType: AnimType.SCALE,
            title: "Failed !",
            desc: error.toString())
          ..show();
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
      // appBar: AppBar(
      //   title: Text("Protect your data"),
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      // leading: bloc.dir.value != "/" ? IconButton(
      //   icon: Icon(Icons.arrow_back),
      //   onPressed: (){
      //     var paths = bloc.dir.value.split("/").toList();
      //     paths.removeLast();
      //     bloc.dir.value = paths.last == "protected" ? "/" : paths.join("/");
      //     bloc.add(GetStoredFiles(path: bloc.dir.value , clearTheList: true));
      //   },
      // ) : null,
      // actions: bloc.isImageSelecting.value ? [
      //   IconButton(icon: Icon(Icons.lock_open), onPressed: (){
      //     // decrypt the selected images
      //     bloc.add(DecryptImages());
      //   }) ,
      //   IconButton(icon: Icon(Icons.close), onPressed: (){
      //     bloc.isImageSelecting.value = false;
      //     bloc.selectedImages.value = List();
      //   })
      // ] : bloc.isFolderSelecting.value ? [
      //   IconButton(icon: Icon(Icons.delete), onPressed: (){
      //     bloc.add(DeleteFolders(folders: bloc.selectedFolder.value));
      //     bloc.isFolderSelecting.value = false;
      //     bloc.selectedFolder.value = List();
      //   }) ,
      //   IconButton(icon: Icon(Icons.close), onPressed: (){
      //     bloc.isFolderSelecting.value = false;
      //     bloc.selectedFolder.value = List();
      //   })
      // ]: [
      //   PopupMenuButton<String>(
      //     onSelected: (String choice){
      //       switch (choice) {
      //         case 'Logout':
      //           bloc.add(LogOut());
      //           break;
      //         case 'Settings':
      //           break;
      //       }
      //     },
      //     itemBuilder: (BuildContext context) {
      //       return {'Logout', 'Settings'}.map((String choice) {
      //         return PopupMenuItem<String>(
      //           value: choice,
      //           child: Text(choice),
      //         );
      //       }).toList();
      //     },
      //   ),
      // ],
      // ),
      floatingActionButton: animatedFloatingActionButtons(
          _floatingButtonController, icons, backgroundColor, foregroundColor, [
        // create folder
        () {
          showCreateNewFolderDialog();
        },
        // encrypt image
        () {
          loadAssets();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                    "Your files : " + exctractCurrentFolderName(bloc.dir.value),
                    style: titleTextStyle)),
                mainContents()
              ],
            ),
          ))
        ],
      ),
    );
  }

  Row buildMenuesRow() {
    return Row(
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
                    bloc.selectedImages.value = List();
                  })
            ]
          : bloc.isFolderSelecting.value
              ? [
                  IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        bloc.add(
                            DeleteFolders(folders: bloc.selectedFolder.value));
                        bloc.isFolderSelecting.value = false;
                        bloc.selectedFolder.value = List();
                      }),
                  IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        bloc.isFolderSelecting.value = false;
                        bloc.selectedFolder.value = List();
                      })
                ]
              : [
                  PopupMenuButton<String>(
                      onSelected: (String choice) {
                        switch (choice) {
                          case 'Logout':
                            bloc.add(LogOut());
                            break;
                          case 'Settings':
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Logout', 'Settings'}.map((String choice) {
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
    );
  }

  Widget mainContents() {
    double screeHeight = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (_) => bloc,
      child: BlocBuilder<EncryptImagesBloc, EncryptState>(
        builder: (context, state) {
          if (state is GotImages) {
            if (state.images.isNotEmpty) {
              return buildGridView(state);
            } else {
              return Container(
                margin: EdgeInsets.only(top: screeHeight / 3),
                child: Center(
                  child: Text("No Encrypted Images Yet ."),
                ),
              );
            }
          } else if (state is GettingImagesFailed) {
            return Container(
              margin: EdgeInsets.only(top: screeHeight / 3),
              child: Center(
                child: Text(state.error),
              ),
            );
          } else if (state is GettingImages) {
            return Container(
              margin: EdgeInsets.only(top: screeHeight / 3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget buildGridView(GotImages state) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0),
            semanticChildCount: 3,
            itemCount: state.images.length,
            itemBuilder: (context, index) {
              var file = state.images[index];
              if (file.file.type == FileType.FOLDER.index) {
                print("paths > ${file.file.name} ,  ${file.file.path}");
                return buildFolderCard(file);
              } else if (file.file.type == FileType.IMAGE.index) {
                return buildImageCard(file);
              } else {
                throw Exception("No matched file type");
              }
            }),
      ),
    );
  }

  Widget buildImageCard(FileWrapper image) {
    return Obx(() => GestureDetector(
          onLongPress:
              !bloc.isFolderSelecting.value && !bloc.isImageSelecting.value
                  ? () {
                      bloc.isImageSelecting.value = true;
                      bloc.selectedImages.add(image);
                    }
                  : null,
          onTap: bloc.isImageSelecting.value && !bloc.isFolderSelecting.value
              ? () {
                  if (!bloc.selectedImages.contains(image)) {
                    bloc.selectedImages.add(image);
                  } else {
                    bloc.selectedImages.remove(image);
                    if (bloc.selectedImages.isEmpty) {
                      bloc.isImageSelecting.value = false;
                    }
                  }
                }
              : () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ShowFullImage(image: image.uint8list)));
                },
          child: Container(
            padding: bloc.selectedImages.contains(image)
                ? EdgeInsets.all(5.0)
                : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: bloc.selectedImages.contains(image) ? Colors.grey : null,
            ),
            child: Hero(
              tag: image.file.id,
              child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: MemoryImage(image.uint8list),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                        offset: Offset(0, 2))
                  ])),
            ),
          ),
        ));
  }

  Widget buildFolderCard(FileWrapper folder) {
    return Obx(() => InkWell(
          onTap: !bloc.isImageSelecting.value && !bloc.isFolderSelecting.value
              ? () {
                  bloc.add(GetStoredFiles(
                      path: folder.file.path + "/" + folder.file.name,
                      clearTheList: true));
                }
              : () {
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
                },
          onLongPress:
              !bloc.isFolderSelecting.value && !bloc.isImageSelecting.value
                  ? () {
                      bloc.isFolderSelecting.value = true;
                      bloc.selectedFolder.add(folder);
                    }
                  : null,
          child: Container(
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
            ),
          ),
        ));
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

  Future<List<AssetEntity>> _pickAsset(PickType type,
      {List<AssetPathEntity> pathList}) async {
    List<AssetEntity> imgList = await PhotoPicker.pickAsset(
      // BuildContext required
      context: context,
      provider: I18nProvider.english,
      pickType: type,

      photoPathList: pathList,
    );

    if (imgList == null || imgList.isEmpty) {
      print("no pick");
      return Future.value(null);
    } else {
      return imgList;
    }
  }

  Future<void> loadAssets() async {
    List<Uint8List> resultList = [];

    try {
      var assetPathList =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      var picked =
          await _pickAsset(PickType.onlyImage, pathList: assetPathList);
      if (picked != null) {
        for (var image in picked) {
          var origin = await image.originBytes;
          resultList.add(origin);
        }
        print("koko > resultList " + resultList.length.toString());
        bloc.add(EncryptImages(images: resultList));
      }
    } on Exception catch (e) {
      bloc.add(PickingImagesError(error: e.toString()));
    }
  }
}
