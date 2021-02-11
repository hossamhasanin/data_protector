import 'package:data_protector/ui/styles.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About us"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Image.asset("assets/images/onboarding3.png"),
              SizedBox(height: 10.0),
              Text(
                "Done by : Hossam Hasanin",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.0),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 10.0),
              Text(
                "This app is made to protect the files on device storage by encrypting them ,"
                "it generates encrypted files the has extension of .hg , "
                " it doesn't share any encrypted file through any external sever , "
                "Only uses the internet to login with some account and save your key on the server enables you "
                "to have a portable account could open it on any device and use it to decrypt your data and that you don't have to write the encryption key by yourself every time",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.left,
              )
            ],
          ),
        ),
      ),
    );
  }
}
