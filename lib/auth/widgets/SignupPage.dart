import 'dart:async';

import 'package:data_protector/auth/blocs/auth_bloc.dart';
import 'package:data_protector/auth/blocs/auth_events.dart';
import 'package:data_protector/auth/blocs/auth_states.dart';
import 'package:data_protector/auth/widgets/PrepareSettings.dart';
import 'package:data_protector/ui/UiHelpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  AuthBloc _authBloc = AuthBloc(authUseCase: Get.find());
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _authBloc.authState.listen((state) {
      print("koko state > " + state.toString());
      if (state is Authenticating) {
        showCustomDialog(
            context: context,
            title: "Wait a bit !",
            children: [CircularProgressIndicator()]);
      } else if (state is SignedUp) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => PrepareSettings()));
      } else if (state is AuthError) {
        showCustomDialog(
            context: context,
            title: "Error bro !",
            children: [Text(state.error)]);
      }
    });
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                      child: Text(
                        'Signup',
                        style: TextStyle(
                            fontSize: 80.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(260.0, 125.0, 0.0, 0.0),
                      child: Text(
                        '.',
                        style: TextStyle(
                            fontSize: 80.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            labelText: 'EMAIL',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            // hintText: 'EMAIL',
                            // hintStyle: ,
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                            labelText: 'PASSWORD ',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                        obscureText: true,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                            labelText: 'NICK NAME ',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      SizedBox(height: 50.0),
                      // Obx(() {
                      //   final state = _authBloc.authState.value;
                      //   if (state is AuthError) {
                      //     AuthError errorState = state;
                      //     return Container(
                      //       decoration: BoxDecoration(
                      //           color: Colors.redAccent[100],
                      //           borderRadius: BorderRadius.circular(15.0)),
                      //       padding: EdgeInsets.all(20.0),
                      //       child: Center(
                      //           child: Column(
                      //         children: [
                      //           Expanded(child: Text(errorState.error))
                      //         ],
                      //       )),
                      //     );
                      //   } else {
                      //     return Container();
                      //   }
                      // }),
                      SizedBox(height: 5.0),
                      GestureDetector(
                        onTap: () {
                          _authBloc.add(Signup(
                              email: _emailController.value.text,
                              password: _passwordController.value.text,
                              username: _usernameController.value.text));
                        },
                        child: Container(
                          height: 40.0,
                          child: Material(
                            borderRadius: BorderRadius.circular(20.0),
                            shadowColor: Theme.of(context).primaryColor,
                            color: Theme.of(context).primaryColor,
                            elevation: 7.0,
                            child: Center(
                              child: Text(
                                'SIGNUP',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        height: 40.0,
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black,
                                  style: BorderStyle.solid,
                                  width: 1.0),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20.0)),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Center(
                              child: Text('Go Back',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat')),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ]));
  }
}
