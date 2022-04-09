import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/viewstates/selection_viewstate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

class FolderCard extends StatelessWidget {
  Rx<SelectionViewState> selectionViewState;
  FileWrapper folder;
  Function onTap;
  Function() onLongPress;
  int index;

  FolderCard(
      {required this.folder,
      required this.index,
      required this.selectionViewState,
      required this.onTap,
      required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
        // setState(() {});
      },
      onLongPress: () {
        onLongPress();
      },
      child: Stack(
        children: [
          Obx(() => selectionViewState.value.selectedFiles[index] != null
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(color: Colors.grey),
                )
              : Container()),
          Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder,
                    color: Colors.blueAccent,
                    size: 46.0,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                    child: Text(
                      folder.file.name,
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
