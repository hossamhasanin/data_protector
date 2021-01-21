import 'package:data_protector/auth/blocs/auth_bloc.dart';
import 'package:data_protector/auth/blocs/auth_events.dart';
import 'package:data_protector/auth/blocs/auth_states.dart';
import 'package:data_protector/encryptImages/widgets/show_encrypted_images_widget.dart';
import 'package:data_protector/ui/UiHelpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrepareSettings extends StatefulWidget {
  @override
  _PrepareSettingsState createState() => _PrepareSettingsState();
}

class _PrepareSettingsState extends State<PrepareSettings> {
  TextEditingController key;

  AuthBloc _authBloc = Get.find<AuthBloc>();

  @override
  void initState() {
    super.initState();
    key = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    _authBloc.authState.listen((state) {
      if (state is AddingSettings) {
        showCustomDialog(context: context ,title: "Wait a bit !" , children: [CircularProgressIndicator()] );
      } else if (state is AddedSettings) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => EncryptedImagesWidget()));
      } else if (state is AddSettingsError){
        showCustomDialog(context: context ,title: "Error bro !" , children: [Text(state.error)]);
      }
    });
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: key,
                decoration: InputDecoration(
                    labelText: 'Set your private encryption key',
                    labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green))),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                onPressed: () {
                  _authBloc.add(SetSettings(key: key.value.text));
                },
                child: Text("Set The key"),
              )
            ],
          )),
    );
  }
}
