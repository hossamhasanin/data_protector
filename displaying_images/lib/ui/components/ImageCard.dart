import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/viewstates/selection_viewstate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageCard extends StatelessWidget {
  Rx<SelectionViewState> selectionViewState;
  FileWrapper image;
  Function onTap;
  Function() onLongPress;
  int index;

  ImageCard(
      {required this.selectionViewState,
      required this.image,
      required this.onLongPress,
      required this.onTap,
      required this.index});

  @override
  Widget build(BuildContext context) {
    // print("koko select card > " + widget.isImageSelecting.value.toString());
    // print("koko select card contains > " +
    //     widget.selectedImages.contains(widget.image).toString());
    print("thumb size > " + image.thumbUint8list!.lengthInBytes.toString());
    return GestureDetector(
        onLongPress: () {
          onLongPress();
        },
        onTap: () {
          onTap();
          // setState(() {});
        },
        child: Stack(children: [
          Obx(() => selectionViewState.value.selectedFiles[index] != null
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(color: Colors.grey),
                )
              : Container()),
          Container(
              width: double.infinity,
              height: double.infinity,
              margin: EdgeInsets.all(5.0),
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Hero(
                tag: image.file.id,
                child: Container(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.memory(
                    image.thumbUint8list!,
                    fit: BoxFit.cover,
                  ),
                )),
              )),
        ]));
  }
}
