import 'package:base/base.dart';
import 'package:displaying_images/logic/controllers/folders_controller.dart';
import 'package:displaying_images/logic/controllers/images_controller.dart';
import 'package:displaying_images/logic/controllers/main_controller.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'FolderCard.dart';
import 'ImageCard.dart';

class FilesGridView extends StatelessWidget {
  final List<FileWrapper> images;
  final ScrollController scrollController;
  final DisplayingImagesController _controller = Get.find();
  final FoldersController _foldersController = Get.find();
  final ImagesController _imagesController = Get.find();

  FilesGridView(
      {Key? key, required this.images, required this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        // controller: scrollController,
        padding: const EdgeInsets.all(8.0),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 5.0, crossAxisSpacing: 5.0),
        //semanticChildCount: images.length,
        physics: ClampingScrollPhysics(),
        itemCount: images.length,
        itemBuilder: (context, index) {
          var file = images[index];
          if (file.file.type == SavedFileType.FOLDER.index) {
            print("paths > ${file.file.name} ,  ${file.file.path}");
            //return buildFolderCard(file);
            return FolderCard(
              folder: file,
              selectionViewState: _controller.selectionViewState,
              index: index,
              onTap: () {
                if (_controller.selectionViewState.value.isSelectingFolders) {
                  _controller.selectFile(file.file.type, index);
                } else {
                  // open the folder
                  _foldersController.openFolder(file.file);
                }
                // if (!bloc.isImageSelecting.value &&
                //     !bloc.isFolderSelecting.value) {
                //   bloc.add(GetStoredFiles(
                //       path: file.file.path + "/" + file.file.name,
                //       clearTheList: true));
                // } else {
                //   if (!bloc.isImageSelecting.value) {
                //     if (!bloc.selectedFolder.contains(file)) {
                //       bloc.selectedFolder.add(file);
                //     } else {
                //       bloc.selectedFolder.remove(file);
                //       if (bloc.selectedFolder.isEmpty) {
                //         bloc.isFolderSelecting.value = false;
                //       }
                //     }
                //   }
                // }
              },
              onLongPress: () {
                print("koko here");
                if (!_controller.selectionViewState.value.isSelectingFolders &&
                    !_controller.selectionViewState.value.isSelectingImages) {
                  _controller.selectFile(file.file.type, index);
                }
              },
            );
          } else if (file.file.type == SavedFileType.IMAGE.index) {
            //return buildImageCard(file);
            return ImageCard(
                image: file,
                selectionViewState: _controller.selectionViewState,
                index: index,
                onLongPress: () {
                  if (!_controller
                          .selectionViewState.value.isSelectingFolders &&
                      !_controller.selectionViewState.value.isSelectingImages) {
                    _controller.selectFile(file.file.type, index);
                  }
                },
                onTap: () async {
                  if (_controller.selectionViewState.value.isSelectingImages) {
                    _controller.selectFile(file.file.type, index);
                  } else {
                    // open the image
                    if (!_controller
                        .selectionViewState.value.isSelectingFolders) {
                      var images = _imagesController.getImagesInCurrentPath();
                      var imageIndex = images.indexOf(file);
                      
                      Get.toNamed(openImageScreen , arguments: [images,_controller.encryptionKey,imageIndex]);
                    }
                  }
                });
          } else {
            throw Exception("No matched file type");
          }
        });
  }
}
