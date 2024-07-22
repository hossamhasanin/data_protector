import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:set_user/logic/controller.dart';
import 'package:shared_ui/shared_ui.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {

  late final SetUserController _loginController;

  late final TextEditingController _nameTextController;
  late final TextEditingController _secretKeyTextController;

  @override
  void initState() {
    super.initState();

    _nameTextController = TextEditingController();
    _secretKeyTextController = TextEditingController();

    _loginController = Get.put(SetUserController(Get.find(),
    showLoadingDialog: (loading){
      if (loading) {
        EasyLoading.show(status: 'wait ...'.tr, dismissOnTap: false);
      } else {
        EasyLoading.dismiss();
      }
    },
    onSetUserSuccess: (){
      Get.offNamed(displayingImagesScreen);
    }, 
    showErrorDialog: (){
        EasyLoading.showError('something wrong happened try again later'.tr, dismissOnTap: true);
    }
    ));

    _loginController.hasDataSet();
  }

  @override
  void dispose() {
    super.dispose();

    _secretKeyTextController.dispose();
    _nameTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usedFormWidth = MediaQuery.of(context).size.width * 0.9;
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Image.asset(
              'assets/images/lock_icon.png',
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16.0),
              width: usedFormWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(color: kLogoBlueColor.withOpacity(0.3), spreadRadius: 5, blurRadius: 80)
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Setup your storage',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameTextController,
                    decoration: InputDecoration(
                      hintText: 'Your name',
                      hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFE2E2E2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 0.0,
                      ),
                    ),
                  ),
          
                  const SizedBox(height: 20),
          
                  TextFormField(
                    controller: _secretKeyTextController,
                    decoration: InputDecoration(
                      hintText: 'Write a secret key to encrypt the files',
                      hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFE2E2E2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 0.0,
                      ),
                      helperText: "You should not tell you secret key to anybody"
                    ),
                  ),
          
                  const SizedBox(height: 20),
          
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _loginController.setUser(_nameTextController.text, _secretKeyTextController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF014492),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}