import 'dart:typed_data';

import 'package:base/Constants.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wifi_p2p/device.dart';
import 'package:wifi_p2p/wifi_p2p.dart';

class TestPackage extends StatelessWidget {
   TestPackage({Key? key}) : super(key: key);

  List<Device> l = [];

  @override
  Widget build(BuildContext context) {
    WifiP2p.discoverPeers;
    WifiP2p.getTransferredData.listen((event) {
      print("koko data "+event.toString());
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("test"),
        actions: [
          IconButton(onPressed: () async {
            // print(await WifiP2p.cancelConnection());
            List<Uint8List> resultList = [];
            List<Uint8List> thumbtList = [];

            try {
              final List<AssetEntity>? picked = await AssetPicker.pickAssets(
                  context,
                  pickerConfig: const AssetPickerConfig(
                      maxAssets: MAX_SELECTED_IMAGES,
                      requestType: RequestType.image,
                      gridThumbnailSize:
                      ThumbnailSize(THUMB_SIZE, THUMB_SIZE),
                      textDelegate: EnglishAssetPickerTextDelegate()));
              if (picked != null) {
                for (var image in picked) {
                  var thumb = await image.thumbnailDataWithSize(
                      const ThumbnailSize(THUMB_SIZE, THUMB_SIZE));
                  var origin = await image.originBytes;
                  resultList.add(origin!);
                  thumbtList.add(thumb!);
                }
                print("koko thumbs size " + thumbtList.length.toString());

                await WifiP2p.startSendingProcess(resultList);

              }
            } catch (e) {
              // bloc.add(PickingImagesError(error: e.toString()));
            }
          }, icon: Icon(Icons.delete))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // WifiP2p.connectToDevice(Map.from(l[0] as Map));
          WifiP2p.connectToDevice(l.firstWhere((element) => element.name.contains("OPPO")));
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Device>>(
          stream: WifiP2p.getPeersList,
          builder: (_ , s){
            // if (s.connectionState == ConnectionState.waiting){
            //   return Center(
            //     child: CircularProgressIndicator(),
            //   );
            // }

            if (s.hasError){
              return Center(
                child: Text(s.error.toString()),
              );
            }

            l = s.data != null ? s.data! : [];
            return Center(
              child: Text(s.data.toString()),
            );
          })
    );
  }
}
