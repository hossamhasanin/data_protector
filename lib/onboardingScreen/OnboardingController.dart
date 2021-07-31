import 'package:base/Constants.dart';
import 'package:data_protector/onboardingScreen/OnBoardingModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  PageController pageController = PageController();
  List<OnboardingModel> pages = [
    OnboardingModel(
        image: "assets/images/onboarding1.png",
        title: "Welcome To $APP_NAME",
        desc:
            "We are here to keep you images safe and secure and just keep you reliefed"),
    OnboardingModel(
        image: "assets/images/onboarding2.png",
        title: "This is by ...",
        desc:
            "We do that by encrypting your images and save it safely on your device"),
    OnboardingModel(
        image: "assets/images/onboarding3.png",
        title: "Internet ?",
        desc:
            "Nope we don't touch your photos and you could keep it all private on your device and if one day someone tried to steal them he can not decrypt them to see without your own encryption key"),
    OnboardingModel(
        image: "assets/images/onboarding4.png",
        title: "Set your own key your self ",
        desc: "You will set your owm key and only you should know it so that if"
            " you transfered the encrypted files to another device you could easily "
            "decrypt them back ,  and don't wory the keys are "
            "also encrypted and kept secure always ,  so wanna start ?!"),
  ];

  RxInt selectedPage = 0.obs;

  goNext(Function fishedOnBoardingBoardsAction) {
    if (selectedPage != pages.length - 1) {
      selectedPage++;
      pageController.nextPage(
          duration: Duration(milliseconds: 700), curve: Curves.linearToEaseOut);
    } else {
      fishedOnBoardingBoardsAction.call();
    }
  }
}
