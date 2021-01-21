import 'package:data_protector/auth/blocs/auth_bloc.dart';
import 'package:data_protector/auth/blocs/auth_events.dart';
import 'package:data_protector/auth/blocs/auth_states.dart';
import 'package:data_protector/auth/widgets/SignupPage.dart';
import 'package:data_protector/encryptImages/widgets/show_encrypted_images_widget.dart';
import 'package:data_protector/ui/UiHelpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  Animation animation, delayedAnimation, muchDelayedAnimation;
  AnimationController animationController;
  TextEditingController _emailController;
  TextEditingController _passwordController;

  AuthBloc _authBloc = Get.find<AuthBloc>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);

    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        curve: Curves.fastOutSlowIn, parent: animationController));

    delayedAnimation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
        parent: animationController));

    muchDelayedAnimation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        curve: Interval(0.8, 1.0, curve: Curves.fastOutSlowIn),
        parent: animationController));
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _authBloc.authState.listen((state) {
      print("koko > "+ state.toString());
      if (state is Authenticating) {
        Get.snackbar("auth", "Authenticating");
      } else if (state is LoggedIn) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => EncryptedImagesWidget()));
      } else if (state is AuthError){
        showCustomDialog(context: context ,title: "Error bro !" , children: [Text(state.error)]);
      }
    });

    _authBloc.isLoggedIn();

    animationController.forward();
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Scaffold(
              resizeToAvoidBottomPadding: false, body: buildLoginForm());
        });
  }

  Widget buildLoginForm() {
    final double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Transform(
          transform:
              Matrix4.translationValues(animation.value * width, 0.0, 0.0),
          child: Container(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                  child: Text(
                    "Hello",
                    style:
                        TextStyle(fontSize: 80.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15.0, 175.0, 0.0, 0.0),
                  child: Text(
                    "There",
                    style:
                        TextStyle(fontSize: 80.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(230.0, 175.0, 0.0, 0.0),
                  child: Text(
                    ".",
                    style: TextStyle(
                        fontSize: 80.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                )
              ],
            ),
          ),
        ),
        Transform(
          transform: Matrix4.translationValues(
              delayedAnimation.value * width, 0.0, 0.0),
          child: Container(
            padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green))),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green))),
                  obscureText: true,
                ),
                SizedBox(height: 5.0),
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
                //         children: [Expanded(child: Text(errorState.error))],
                //       )),
                //     );
                //   } else {
                //     return Container();
                //   }
                // }),
                SizedBox(height: 5.0),
                Container(
                  alignment: Alignment(1.0, 0),
                  padding: EdgeInsets.only(top: 15.0, left: 20.0),
                  child: InkWell(
                    child: Text(
                      "Forgot Password",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Montserrat",
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                SizedBox(height: 40.0),
                Container(
                  height: 40.0,
                  child: Material(
                    borderRadius: BorderRadius.circular(20.0),
                    shadowColor: Colors.greenAccent,
                    color: Colors.green,
                    child: GestureDetector(
                      onTap: () {
                        _authBloc.add(Login(
                            email: _emailController.value.text,
                            password: _passwordController.value.text));
                      },
                      child: Center(
                        child: Text(
                          "LOGIN",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Center(
                        //   child: ImageIcon(AssetImage("assets/facebook.png")),
                        // ),
                        SizedBox(width: 10.0),
                        Center(
                          child: Text(
                            "Login with facebook",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Montserrat"),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15.0),
        Transform(
          transform: Matrix4.translationValues(
              muchDelayedAnimation.value * width, 0.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "New to Spotify ?",
                style: TextStyle(fontFamily: "Montserrat"),
              ),
              SizedBox(width: 5.0),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => SignupPage()));
                },
                child: Text(
                  "Register",
                  style: TextStyle(
                      color: Colors.green,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
