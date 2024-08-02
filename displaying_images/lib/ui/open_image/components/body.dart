import 'package:displaying_images/logic/controllers/open_image_controller.dart';
import 'package:displaying_images/logic/image_file_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'display_image.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late final OpenImageController _controller;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    List args = Get.arguments;

    _controller = Get.put(OpenImageController(
        args[0] as List<FileWrapper>, args[1] as String));
    int selectedImageToOpen = args[2] as int;
    _pageController = PageController(initialPage: selectedImageToOpen);
    _controller.listenToReadyImageStream();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: _pageController,
        itemBuilder: (_, index) {
          return DisplayImage(index: index);
        },
        itemCount: _controller.images.length);
  }
}
