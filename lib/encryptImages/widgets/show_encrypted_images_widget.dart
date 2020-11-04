import 'dart:typed_data';

import 'package:data_protector/encryptImages/blocs/encrypt_bloc.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_events.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_states.dart';
import 'package:data_protector/encryptImages/image_file_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';

class EncryptedImagesWidget extends StatefulWidget {
  @override
  _EncryptedImagesWidgetState createState() => _EncryptedImagesWidgetState();
}

class _EncryptedImagesWidgetState extends State<EncryptedImagesWidget> {

  final EncryptImagesBloc bloc = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Protect your data"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadAssets,
        child: Icon(Icons.add , color: Colors.white,),
        backgroundColor: Colors.blue,
      ),
      body: BlocProvider(
        create: (_)=> bloc,
        child: BlocBuilder<EncryptImagesBloc , EncryptState>(
          builder: (context , state){
            if (state is GotImages){
              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3
                  ),
                  semanticChildCount: 3,
                  itemCount: state.images.length,
                  itemBuilder: (context , index){
                     return buildImageCard(state.images[index]);
                  });
            } else if (state is GettingImagesFailed){
              return Center(
                child: Text(state.error),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget buildImageCard(ImageFileWrapper image){
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: MemoryImage(image.uint8list)),
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0
          )
        ]
      ),
    );
  }

  Future<List<AssetEntity>> _pickAsset(PickType type, {List<AssetPathEntity> pathList}) async {
    List<AssetEntity> imgList = await PhotoPicker.pickAsset(
      // BuildContext required
      context: context,
      provider: I18nProvider.english,
      pickType: type,

      photoPathList: pathList,
    );

    if (imgList == null || imgList.isEmpty) {
      print("no pick");
      return Future.value(null);
    } else {
      return imgList;
    }
  }

  Future<void> loadAssets() async {
    List<Uint8List> resultList = [];

    try {
      var assetPathList = await PhotoManager.getAssetPathList(type: RequestType.image);
      (await _pickAsset(PickType.onlyImage , pathList: assetPathList)).forEach((image) async {
        resultList.add(await image.originBytes);
      });
      bloc.add(EncryptImages(images: resultList));
    } on Exception catch (e) {
      bloc.add(PickingImagesError(error: e.toString()));
    }
  }


}
