import 'dart:typed_data';

import 'package:data_protector/encryptImages/blocs/encrypt_bloc.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_events.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_states.dart';
import 'package:data_protector/encryptImages/wrappers/image_file_wrapper.dart';
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
  ScrollController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = ScrollController();

    bloc.add(GetAllImages());
  }

  @override
  Widget build(BuildContext context) {
    return Obx( () => Scaffold(
        appBar: AppBar(
          title: Text("Protect your data"),
          automaticallyImplyLeading: false,
          actions: bloc.isSelecting.value ? [
            IconButton(icon: Icon(Icons.lock_open), onPressed: (){
              // decrypt the selected images
              bloc.add(DecryptImages());
            }) ,
            IconButton(icon: Icon(Icons.close), onPressed: (){
              bloc.isSelecting.value = false;
              bloc.selectedImages.value = List();
            })
          ] : [],
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
                if (state.images.isNotEmpty){
                  return buildGridView(state);
                } else {
                  return Center(
                    child: Text("No Encrypted Images Yet ."),
                  );
                }
              } else if (state is GettingImagesFailed){
                return Center(
                  child: Text(state.error),
                );
              } else if (state is GettingImages){
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildGridView(GotImages state){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0
          ),
          semanticChildCount: 3,
          itemCount: state.images.length,
          itemBuilder: (context , index){
            return buildImageCard(state.images[index]);
          }),
    );
  }

  Widget buildImageCard(ImageFileWrapper image){
    return GestureDetector(
      onLongPress: !bloc.isSelecting.value ? (){
        bloc.isSelecting.value = true;
        bloc.selectedImages.add(image);
      }: null,
      onTap: bloc.isSelecting.value ? (){
        if (!bloc.selectedImages.contains(image)){
          bloc.selectedImages.add(image);
        } else {
          bloc.selectedImages.remove(image);
          if (bloc.selectedImages.isEmpty){
            bloc.isSelecting.value = false;
          }
        }
      }: null,
      child: Obx(
        ()=> Container(
          color: bloc.selectedImages.contains(image) ? Colors.grey: null,
          padding: bloc.selectedImages.contains(image) ? EdgeInsets.all(5.0) : null,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: MemoryImage(image.uint8list),
                  fit: BoxFit.cover
              ),
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0
                )
              ]
            ),
          ),
        ),
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
      var picked = await _pickAsset(PickType.onlyImage , pathList: assetPathList);
      if (picked != null){
        for (var image in picked){
          var origin = await image.originBytes;
          resultList.add(origin);
        }
        print("koko > resultList "+ resultList.length.toString());
        bloc.add(EncryptImages(images: resultList));
      }
    } on Exception catch (e) {
      bloc.add(PickingImagesError(error: e.toString()));
    }
  }

  showAddListDialog(BuildContext context){
    Dialog dialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      backgroundColor: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Be Notified !",
              style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.white
              ),
            ),
            SizedBox(height: 20.0,),
            Text(
              "To protect your privacy the app can not remove the images that you encrypted it from the gallery so please go delete them from there because now it has been encrypted by the app here you can see it .",
              style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: Colors.white
              ),
            ),
            RaisedButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Text("Go to the gallery >" , style: TextStyle(color: Colors.white),),
            )
          ],
        ),
      ),
    );
    showDialog(context: context , builder: (BuildContext context) => dialog);
  }

}
