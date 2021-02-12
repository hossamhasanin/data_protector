import 'dart:typed_data';

import 'package:flutter/material.dart';

class ShowFullImage extends StatefulWidget {
  Uint8List image;

  ShowFullImage({this.image});

  @override
  _ShowFullImageState createState() => _ShowFullImageState();
}

class _ShowFullImageState extends State<ShowFullImage> {
  @override
  Widget build(BuildContext context) {
    print("len > open photo >" + widget.image.lengthInBytes.toString());
    print("len > open photo name >" + widget.image.lengthInBytes.toString());

    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Image.memory(widget.image)),
    );
  }
}
