import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:displaying_images/logic/viewstates/selection_viewstate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

// ignore: must_be_immutable
class FolderCard extends StatelessWidget {
  Rx<SelectionViewState> selectionViewState;
  FileWrapper folder;
  Function onTap;
  Function() onLongPress;
  int index;

  FolderCard(
      {Key? key, required this.folder,
      required this.index,
      required this.selectionViewState,
      required this.onTap,
      required this.onLongPress}) : super(key: key);

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
          Obx(() {
            return AnimatedOpacity(
              opacity: selectionViewState.value.selectedFiles[index] != null
                  ? 1.0
                  : 0.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              ),
            );
          }),
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
                    child: Obx(() {
                      return Text(
                        folder.file.name,
                        style: selectionViewState.value.selectedFiles[index] !=
                                null
                            ? subTitleTextStyleWhite
                            : subTitleTextStyle,
                      );
                    }),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
