import 'package:flutter/material.dart';

class ImagesSelectedMenu extends StatelessWidget {
  final Function() decryptImages;
  final Function() cancelSelection;
  final Function() deleteImages;
  final Function() shareImages;

  const ImagesSelectedMenu(
      {Key? key,
      required this.decryptImages,
      required this.cancelSelection,
      required this.deleteImages,
      required this.shareImages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            IconButton(
                icon: const Icon(
                  Icons.lock_open,
                  color: Colors.white,
                ),
                onPressed: () {
                  // decrypt the selected images
                  decryptImages();
                }),
            IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  cancelSelection();
                })
          ],
        ),
        Column(
          children: [
            IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: () {
                  // decrypt the selected images
                  deleteImages();
                }),
            // IconButton(
            //     icon: const Icon(
            //       Icons.share,
            //       color: Colors.white,
            //     ),
            //     onPressed: () {
            //       shareImages();
            //     })
          ],
        ),
      ],
    );
  }
}
