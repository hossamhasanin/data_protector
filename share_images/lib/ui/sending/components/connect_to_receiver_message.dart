import 'package:flutter/material.dart';
import 'package:share_images/logic/models/device_peer.dart';

class ConnectToReceiverMessage extends StatelessWidget {
  final DevicePeer device;
  const ConnectToReceiverMessage({Key? key, required this.device})
      : super(key: key);

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
          Text(
            "Device name ${device.name}",
            style: const TextStyle(
              fontFamily: "jakarta",
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "try to connect to it from other device to transfer the data ...",
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}
