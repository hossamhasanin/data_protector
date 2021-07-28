import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'show_full_image.dart';

class ImageCard extends StatefulWidget {
  RxBool isFolderSelecting;
  RxBool isImageSelecting;
  RxList<FileWrapper> selectedImages;
  FileWrapper image;
  Function onTap;
  Function() onLongPress;

  ImageCard({
    required this.selectedImages,
    required this.isImageSelecting,
    required this.isFolderSelecting,
    required this.image,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  @override
  Widget build(BuildContext context) {
    // print("koko select card > " + widget.isImageSelecting.value.toString());
    // print("koko select card contains > " +
    //     widget.selectedImages.contains(widget.image).toString());
    print("thumb size > " +
        widget.image.thumbUint8list!.lengthInBytes.toString());
    return GestureDetector(
        onLongPress: widget.onLongPress,
        onTap: () {
          widget.onTap.call();
          // setState(() {});
        },
        child: Stack(children: [
          Obx(() => widget.selectedImages.contains(widget.image)
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey),
                )
              : Container()),
          Container(
              width: double.infinity,
              height: double.infinity,
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Hero(
                tag: widget.image.file.id,
                child: Container(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.memory(
                    widget.image.thumbUint8list!,
                    fit: BoxFit.cover,
                  ),
                )),
              )),
        ]));
  }
}
