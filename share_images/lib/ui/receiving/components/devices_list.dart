import 'package:flutter/material.dart';
import 'package:share_images/logic/models/device_peer.dart';

class DevicesList extends StatelessWidget {
  final List<DevicePeer> devices;
  final Function(DevicePeer) connectToDevice;
  final String senderTringToConnectWith;
  const DevicesList(
      {Key? key,
      required this.devices,
      required this.connectToDevice,
      required this.senderTringToConnectWith})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (_, index) {
            return ListTile(
              title: Text(devices[index].name),
              subtitle: Text(devices[index].address),
              trailing: senderTringToConnectWith == devices[index].address
                  ? const SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: senderTringToConnectWith.isEmpty
                          ? () {
                              connectToDevice(devices[index]);
                            }
                          : null,
                    ),
            );
          },
          itemCount: devices.length,
        ),
      ),
    );
  }
}
