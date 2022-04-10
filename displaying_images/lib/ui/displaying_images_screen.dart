import 'dart:io';
import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:displaying_images/logic/controllers/main_controller.dart';
import 'package:displaying_images/logic/controllers/images_controller.dart';
import 'package:displaying_images/ui/components/body.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class DisplayingImagesScreen extends StatelessWidget {
  final DisplayingImagesController _controller =
      Get.put(DisplayingImagesController(Get.find(), Get.find()));
  final ImagesController _imagesController = Get.find();
  final GlobalKey<AnimatedFloatingButtonState> animatedButtonKey = GlobalKey();
  final GlobalKey<BodyState> bodyKey = GlobalKey();
  DisplayingImagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        key: bodyKey,
        animatedButtonKey: animatedButtonKey,
      ),
      backgroundColor: Colors.blue,
      // floatingActionButton: FloatingActionButton(onPressed: (){
      //   File file = File(name: "koko", id: "0", path: "/", type: SavedFileType.FOLDER.index);
      //
      //   _controller.addFolder(file);
      // }
      floatingActionButton: AnimatedFloatingButton(
          key: animatedButtonKey,
          buttonsIcons: const [
            Icons.create_new_folder,
            Icons.add_photo_alternate_outlined,
            Icons.file_download
          ],
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).primaryColor,
          action: [
            // create folder
            () async {
              bodyKey.currentState!.createNewFolder();
            },
            // encrypt image
            () async {
              List<Uint8List> resultList = [];
              List<Uint8List> thumbtList = [];

              try {
                animatedButtonKey.currentState!.cancelButton();
                final List<AssetEntity>? picked = await AssetPicker.pickAssets(
                    context,
                    pickerConfig: const AssetPickerConfig(
                        maxAssets: MAX_SELECTED_IMAGES,
                        requestType: RequestType.image,
                        gridThumbnailSize:
                            ThumbnailSize(THUMB_SIZE, THUMB_SIZE),
                        textDelegate: EnglishAssetPickerTextDelegate()));
                if (picked != null) {
                  for (var image in picked) {
                    var thumb = await image.thumbnailDataWithSize(
                        const ThumbnailSize(THUMB_SIZE, THUMB_SIZE));
                    var origin = await image.originBytes;
                    resultList.add(origin!);
                    thumbtList.add(thumb!);
                  }
                  print("koko thumbs size " + thumbtList.length.toString());
                  _imagesController.encryptImages(resultList, thumbtList);
                }
              } catch (e) {
                // bloc.add(PickingImagesError(error: e.toString()));
              }
            },
            // import encrypted files to the app
            () async {
              FilePickerResult? result =
                  await FilePicker.platform.pickFiles(allowMultiple: true);

              if (result != null) {
                List<File> files =
                    result.paths.map((path) => File(path!)).toList();
                _imagesController.importZipedImages(files);
              }
            }
          ]),
    );
  }
}
