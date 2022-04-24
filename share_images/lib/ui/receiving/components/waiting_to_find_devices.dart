import 'package:flutter/material.dart';

class WaitingToFindDevices extends StatelessWidget {
  const WaitingToFindDevices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/find_device.jpg"),
          const SizedBox(
            height: 20.0,
          ),
          const Text(
            "Wait I am looking for devices ...",
            style: TextStyle(
              fontFamily: "jakarta",
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
