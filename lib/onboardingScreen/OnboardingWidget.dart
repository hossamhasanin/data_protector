// import 'package:data_protector/onboardingScreen/OnboardingController.dart';
// import 'package:data_protector/ui/styles.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:data_protector/auth/widgets/LoginPage.dart';
//
// class OnboardingWidget extends GetView<OnboardingController> {
//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Stack(
//         children: [
//           PageView.builder(
//               onPageChanged: controller.selectedPage,
//               controller: controller.pageController,
//               itemCount: controller.pages.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//                   child: Column(
//                     children: [
//                       SizedBox(height: height / 6),
//                       Image.asset(controller.pages[index].image),
//                       SizedBox(height: 10.0),
//                       Text(
//                         controller.pages[index].title,
//                         style: onBoardingTitleTextStyle,
//                       ),
//                       SizedBox(height: 10.0),
//                       Text(
//                         controller.pages[index].desc,
//                         style: subTitleTextStyle,
//                         textAlign: TextAlign.center,
//                       )
//                     ],
//                   ),
//                 );
//               }),
//           Positioned(
//             bottom: 40.0,
//             left: 30.0,
//             child: Obx(
//               () => Row(
//                   children: List.generate(
//                       controller.pages.length,
//                       (index) => Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: Container(
//                               width: 12.0,
//                               height: 12.0,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: controller.selectedPage.value == index
//                                     ? Color(0xFFf17b0f)
//                                     : Colors.grey,
//                               ),
//                             ),
//                           ))),
//             ),
//           ),
//           Positioned(
//               bottom: 40.0,
//               right: 30.0,
//               child: Obx(() => FloatingActionButton(
//                   onPressed: () {
//                     controller.goNext(() => Navigator.push(context,
//                         MaterialPageRoute(builder: (_) => LoginPage())));
//                   },
//                   child: Text(
//                       controller.selectedPage.value ==
//                               controller.pages.length - 1
//                           ? "Start"
//                           : "Next",
//                       style: TextStyle(color: Colors.white)))))
//         ],
//       ),
//     );
//   }
// }
