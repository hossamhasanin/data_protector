import 'package:flutter/material.dart';

class FolderSelectedMenu extends StatelessWidget {
  final Function() deleteAllFolders;
  final Function() cancelSelecting;

  const FolderSelectedMenu(
      {Key? key, required this.deleteAllFolders, required this.cancelSelecting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              deleteAllFolders();
            }),
        IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              cancelSelecting();
            })
      ],
    );
  }
}
