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
  Function onLongPress;

  ImageCard({
    this.selectedImages,
    this.isImageSelecting,
    this.isFolderSelecting,
    this.image,
    this.onLongPress,
    this.onTap,
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

    return GestureDetector(
        onLongPress: widget.onLongPress,
        onTap: () {
          widget.onTap.call();
          setState(() {});
        },
        child: Container(
            padding: widget.selectedImages.contains(widget.image)
                ? EdgeInsets.all(5.0)
                : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: widget.selectedImages.contains(widget.image)
                  ? Colors.grey
                  : null,
            ),
            child: Hero(
              tag: widget.image.file.id,
              child: Container(
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.memory(
                  widget.image.uint8list,
                  fit: BoxFit.cover,
                ),
              )),
            )));
  }
}