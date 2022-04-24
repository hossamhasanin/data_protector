import 'package:flutter/material.dart';

import 'components/body.dart';

class SendingScreen extends StatelessWidget {
  const SendingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Sending ...",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: const Body());
  }
}
