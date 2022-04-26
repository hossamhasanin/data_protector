import 'package:displaying_images/logic/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class PathTextWidget extends StatelessWidget {
  final String path;
  const PathTextWidget({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "Your files : " + path,
      style: titleTextStyle,
    );
  }
}
