import 'package:flutter/material.dart';
import 'package:share_images/logic/item.dart';

class SendingFilesList extends StatelessWidget {
  final List<Item> files;
  final bool dataCouldNotBeSent;
  const SendingFilesList(
      {Key? key, required this.files, required this.dataCouldNotBeSent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            leading: files[index].image != null
                ? Image.memory(
                    files[index].image!,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.insert_drive_file),
            title: Text(
              files[index].name,
              style: TextStyle(
                color: dataCouldNotBeSent ? Colors.grey : Colors.black,
                fontFamily: "jakarta",
              ),
            ),
            subtitle: Text("${files[index].progress}%"),
            trailing: CircularProgressIndicator(
              value: files[index].progress / 100,
            ),
          );
        },
        itemCount: files.length,
      ),
    );
  }
}
