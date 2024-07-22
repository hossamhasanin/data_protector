import 'package:base/Constants.dart';
import 'package:displaying_images/logic/controllers/images_controller.dart';
import 'package:displaying_images/logic/controllers/main_controller.dart';
import 'package:displaying_images/logic/models/encrypt_image_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'components/body.dart';

class DisplayingImagesScreen extends StatelessWidget {
  late final ImagesController _imagesController;
  final GlobalKey<AnimatedFloatingButtonState> animatedButtonKey = GlobalKey();
  final GlobalKey<BodyState> bodyKey = GlobalKey();
  DisplayingImagesScreen({Key? key}) : super(key: key){
    Get.put(DisplayingImagesController(Get.find()));
    _imagesController = Get.find();
  }

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
              List<EncryptImageWrapper> imagesToEncrypt = [];

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
                    var imageFile = await image.originFile;
                    var imageApsolutePath = imageFile!.path;
                    var thumb = await image.thumbnailDataWithSize(
                        const ThumbnailSize(THUMB_SIZE, THUMB_SIZE));
                    // var origin = await image.originBytes;
                    imagesToEncrypt.add(EncryptImageWrapper(
                        imageApsolutePath: imageApsolutePath,
                        id: image.id,
                        thumbnail: thumb!));
                  }
                  print(
                      "koko thumbs size " + imagesToEncrypt.length.toString());
                  await _imagesController.encryptImages(imagesToEncrypt);
                }
              } catch (e) {
                print("koko $e");
                // bloc.add(PickingImagesError(error: e.toString()));
              }
            },
            // import encrypted files to the app
            () async {
              _imagesController.showSelectReceivingMethodeDialog();
            }
          ]),
    );
  }
}
