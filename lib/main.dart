import 'dart:io';
import 'dart:typed_data';

import 'package:data_protector/encryptImages/widgets/show_encrypted_images_widget.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Protect your data',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List images = List();
  String _error;
  final key = Encrypt.Key.fromUtf8("WKOPoDUeQzTXYo7RA5W6Cg==");
  final iv = Encrypt.IV.fromLength(16);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EncryptedImagesWidget(),
      appBar: AppBar(
        title: Text("Protect your data"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadAssets,
        child: Icon(Icons.add , color: Colors.white,),
        backgroundColor: Colors.blue,
      ),
    );
  }


  Widget buildGridView() {
    if (images != null)
      return GridView.count(
        crossAxisCount: 3,
        children: List.generate(images.length, (index) {
          return Container(
              width: 300.0,
              height: 300.0,
              child: Image.memory(
                images[index] ,
                width: 300.0,
                height: 300.0,));
        }),
      );
    else
      return Container(color: Colors.white);
  }

  Future<File> saveImage(Uint8List image) async {
    var permission = Permission.storage;
    if (await permission.status.isGranted){
      try {
        var dir = await getExternalStorageDirectory();
        var testdir = await new Directory('${dir.path}/protected').create(recursive: true);
        print(testdir.path);
        return new File("${testdir.path}/${DateTime.now().toUtc().toIso8601String()}.hg")
          ..writeAsBytesSync(image);
      } catch (e) {
        print(e);
        return null;
      }
    } else {
      await permission.request();
      return saveImage(image);
    }
  }

  Encrypt.Encrypted encrypt(Uint8List bytes){
    final encrypter = Encrypt.Encrypter(Encrypt.AES(key));
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    return encrypted;
  }
  List<int> decrypt(Encrypt.Encrypted bytes){
      final encrypter = Encrypt.Encrypter(Encrypt.AES(key));
      final decrypted = encrypter.decryptBytes(bytes, iv: iv);
      return decrypted;
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
    List<Uint8List> actualImages = [];
    List<Uint8List> decs = [];
    List<Uint8List> ims = [];
    List<String> ids = [];
    List<Encrypt.Encrypted> encryptedImages = [];
    setState(() {
      images = List();
    });

    List<AssetEntity> resultList;
    String error;

    try {
      var assetPathList = await PhotoManager.getAssetPathList(type: RequestType.image);
      resultList = await _pickAsset(PickType.onlyImage , pathList: assetPathList);
      // resultList = [(await assetPathList[1].assetList)[1]];
      for(var image in resultList){
        Uint8List im = await image.originBytes;

        var enc = encrypt(im);
        encryptedImages.add(enc);
        ims.add(im);
        ids.add(image.id);
        await saveImage(enc.bytes);
      }
      // final List<String> deleteResult = await PhotoManager.editor.deleteWithIds(ids);

      // print(deleteResult.length);
    } on Exception catch (e) {
      error = e.toString();
    }

    print("koko enc > "+ encryptedImages.length.toString());

    for (var encImage in encryptedImages){
      var dec = decrypt(encImage);
      decs.add(Uint8List.fromList(dec));
      actualImages.add(Uint8List.fromList(dec));
    }
    //assert (decs[0].toString() == ims[0].toString());

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      print("koko > "+actualImages.length.toString());
      images = ims;
      print("koko > "+images.length.toString());
      if (error == null) _error = 'No Error Dectected';
    });
  }

}

