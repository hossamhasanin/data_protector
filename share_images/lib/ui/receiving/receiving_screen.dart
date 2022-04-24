import 'package:flutter/material.dart';

import 'components/body.dart';

class ReceivingScreen extends StatelessWidget {
  const ReceivingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Receiving ...",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: const Body());
  }
}
