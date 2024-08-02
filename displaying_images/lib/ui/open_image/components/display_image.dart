import 'package:displaying_images/logic/controllers/open_image_controller.dart';
import 'package:displaying_images/logic/error_codes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisplayImage extends StatefulWidget {
  final int index;
  const DisplayImage({Key? key, required this.index}) : super(key: key);

  @override
  State<DisplayImage> createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  final OpenImageController _controller = Get.find();
  @override
  void initState() {
    super.initState();
    _controller.loadImage(widget.index);
    print("koko display image " + widget.index.toString());
  }

  @override
  void dispose() {
    print("koko dispose image " + widget.index.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GetBuilder<OpenImageController>(
        init: _controller,
        id: widget.index,
        builder: (controller) {
          var viewState = controller.viewState;

          if (viewState.error.isNotEmpty) {
            return Center(
              child: Text(
                translateErrorCodes(viewState.error),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          return AnimatedCrossFade(
            firstChild: SizedBox(
              width: size.width,
          height: size.height,
              child: Image.memory(viewState.thumbImageBytes, fit: BoxFit.contain,)),
            secondChild: SizedBox(
              width: size.width,
          height: size.height,
              child: Image.memory(viewState.currentImageBytes, fit: BoxFit.contain,)),
            crossFadeState: viewState.currentImageBytes.isNotEmpty ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 500),
          );
        });
  }
}
