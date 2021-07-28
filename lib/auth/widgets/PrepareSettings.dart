import 'package:data_protector/auth/blocs/auth_bloc.dart';
import 'package:data_protector/auth/blocs/auth_events.dart';
import 'package:data_protector/auth/blocs/auth_states.dart';
import 'package:data_protector/encryptImages/widgets/show_encrypted_images_widget.dart';
import 'package:data_protector/ui/UiHelpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrepareSettings extends StatefulWidget {
  @override
  _PrepareSettingsState createState() => _PrepareSettingsState();
}

class _PrepareSettingsState extends State<PrepareSettings>
    with WidgetsBindingObserver {
  late TextEditingController key;

  AuthBloc _authBloc = AuthBloc(authUseCase: Get.find());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    key = TextEditingController();
  }

  @override
  void dispose() {
    _authBloc.close();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached) {
      print("koko closing");
    } else if (state == AppLifecycleState.paused) {
      print("koko paused");
    } else if (state == AppLifecycleState.inactive) {
      print("koko inactive");
      _authBloc.add(SetKeyInComplete());
    }
  }

  @override
  Widget build(BuildContext context) {
    _authBloc.authState.listen((state) {
      print("koko PrepareSettings state > " + state.toString());
      if (state is AddingSettings) {
        showCustomDialog(
            context: context,
            title: "Wait a bit !",
            children: [CircularProgressIndicator()]);
      } else if (state is AddedSettings) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => EncryptedImagesWidget()));
      } else if (state is AddSettingsError) {
        showCustomDialog(
            context: context,
            title: "Error bro !",
            children: [Text(state.error)]);
      }
    });
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.0,
                    ),
                    Container(
                      height: 200.0,
                      width: 200.0,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/lock_im.png"))),
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    Text(
                      "You would set your own key for encryption and this key will be used"
                      " by the encryption algorithm but be careful no one except you should know it",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700], fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
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
                    SizedBox(height: 70.0),
                    RaisedButton(
                      onPressed: () {
                        if (key.value.text.isNotEmpty && key.value.text != null)
                          _authBloc.add(SetSettings(key: key.value.text));
                      },
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        "Set The key",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
