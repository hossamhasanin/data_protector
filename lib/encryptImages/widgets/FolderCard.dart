import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
import 'package:data_protector/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FolderCard extends StatefulWidget {
  RxBool isFolderSelecting;
  RxBool isImageSelecting;
  RxList<FileWrapper> selectedFolder;
  FileWrapper folder;
  Function onTap;
  Function() onLongPress;

  FolderCard(
      {required this.isFolderSelecting,
      required this.isImageSelecting,
      required this.folder,
      required this.selectedFolder,
      required this.onTap,
      required this.onLongPress});

  @override
  _FolderCardState createState() => _FolderCardState();
}

class _FolderCardState extends State<FolderCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap.call();
        setState(() {});
      },
      onLongPress: widget.onLongPress,
      child: Stack(
        children: [
          Obx(() => widget.selectedFolder.contains(widget.folder)
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey),
                )
              : Container()),
          Container(
              width: double.infinity,
              height: double.infinity,
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
                  Expanded(
                    child: Text(
                      widget.folder.file.name,
                      style: subTitleTextStyle,
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
