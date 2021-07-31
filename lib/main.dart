import 'package:base/Constants.dart';
import 'package:data_protector/auth/widgets/LoginPage.dart';
import 'package:data_protector/dependencies.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_events.dart';
import 'package:data_protector/onboardingScreen/OnboardingWidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: APP_NAME,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  GetStorage box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return error(snapshot.error.toString());
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            injection();
            return box.hasData("notFirstTime") ||
                    box.read("notFirstTime") != null
                ? LoginPage()
                : OnboardingWidget();
            // return Container();
            // if (box.hasData("notFirstTime") ||
            //     box.read("notFirstTime") != null) {
            //   Navigator.of(context).pushReplacement(
            //       MaterialPageRoute(builder: (_) => LoginPage()));
            // } else {
            //   Navigator.of(context).pushReplacement(
            //       MaterialPageRoute(builder: (_) => OnboardingWidget()));
            // }
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return loading();
        },
      ),
    );
  }

  Widget loading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget error(String mess) {
    return Center(
      child: Text(mess),
    );
  }
}
