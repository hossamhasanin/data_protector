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
  Function onLongPress;

  FolderCard(
      {this.isFolderSelecting,
      this.isImageSelecting,
      this.folder,
      this.selectedFolder,
      this.onTap,
      this.onLongPress});

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
      child: Container(
          color: widget.selectedFolder.contains(widget.folder)
              ? Colors.grey
              : null,
          padding: widget.selectedFolder.contains(widget.folder)
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
                widget.folder.file.name,
                style: subTitleTextStyle,
              )
            ],
          )),
    );
  }
}
