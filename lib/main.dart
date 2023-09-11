import 'package:base/Constants.dart';
import 'package:base/base.dart';
import 'package:base/encrypt/Encrypt.dart';
import 'package:data_protector/auth/widgets/LoginPage.dart';
import 'package:data_protector/data/user/user_supplier.dart';
import 'package:data_protector/data/user/user_supplier_imp.dart';
import 'package:data_protector/dependencies.dart';
import 'package:data_protector/encryptImages/blocs/encrypt_events.dart';
import 'package:data_protector/onboardingScreen/OnboardingWidget.dart';
import 'package:displaying_images/logic/helper_functions.dart';
import 'package:displaying_images/ui/displaying_images/displaying_images_screen.dart';
import 'package:displaying_images/ui/open_image/open_image_screen.dart';
import 'package:displaying_images/ui/t.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_images/ui/receiving/receiving_screen.dart';
import 'package:share_images/ui/sending/sending_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Hive.initFlutter();
  injection();
  UserSupplier supplier = UserSupplierImp();
  Encrypt encrypt = Get.find();
  await supplier.cacheUser(User(
      id: "0",
      email: "Hossam",
      encryptionKey: encrypt.hash("popo"),
      name: "Hossam"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: APP_NAME,
        getPages: [
          GetPage(name: sendImagesScreen, page: () => SendingScreen()),
          GetPage(name: receiveImagesScreen, page: () => ReceivingScreen()),
          GetPage(
              name: displayingImagesScreen,
              page: () => DisplayingImagesScreen()),
          GetPage(name: openImageScreen, page: () => OpenImageScreen()),
        ],
        home: StatefulBuilder(
          builder: (_, setState) {
            return FutureBuilder<bool>(
                future: requestRequiredPermissions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Text("Couldn't check the permisions"),
                      ),
                    );
                  }

                  if (snapshot.data!) {
                    return DisplayingImagesScreen();
                    // return OpenImageScreen();
                  } else {
                    return Scaffold(
                      body: Center(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              "Sorry you must accept the required permissions"),
                          SizedBox(
                            height: 10.0,
                          ),
                          ElevatedButton(
                            child: Text("Try again"),
                            onPressed: () {
                              setState(() {});
                            },
                          )
                        ],
                      )),
                    );
                  }
                });
          },
        )
        // home: TestPackage(),
        );
  }
}


//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final Future<FirebaseApp> _initialization = Firebase.initializeApp();
//   GetStorage box = GetStorage();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder(
//         // Initialize FlutterFire:
//         future: _initialization,
//         builder: (context, snapshot) {
//           // Check for errors
//           if (snapshot.hasError) {
//             return error(snapshot.error.toString());
//           }
//
//           // Once complete, show your application
//           if (snapshot.connectionState == ConnectionState.done) {
//             injection();
//             return box.hasData("notFirstTime") ||
//                     box.read("notFirstTime") != null
//                 ? LoginPage()
//                 : OnboardingWidget();
//             // return Container();
//             // if (box.hasData("notFirstTime") ||
//             //     box.read("notFirstTime") != null) {
//             //   Navigator.of(context).pushReplacement(
//             //       MaterialPageRoute(builder: (_) => LoginPage()));
//             // } else {
//             //   Navigator.of(context).pushReplacement(
//             //       MaterialPageRoute(builder: (_) => OnboardingWidget()));
//             // }
//           }
//
//           // Otherwise, show something whilst waiting for initialization to complete
//           return loading();
//         },
//       ),
//     );
//   }
//
//   Widget loading() {
//     return Center(
//       child: CircularProgressIndicator(),
//     );
//   }
//
//   Widget error(String mess) {
//     return Center(
//       child: Text(mess),
//     );
//   }
// }
