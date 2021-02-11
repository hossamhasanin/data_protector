import 'package:base/datasource/network/AuthDataSource.dart';
import 'package:base/datasource/network/FirebaseAuthDataSource.dart';
import 'package:data_protector/auth/AuthUseCase.dart';
import 'package:data_protector/auth/blocs/auth_bloc.dart';
import 'package:get/get.dart';
import 'encryptImages/encrypt_images_use_case.dart';

import 'package:data_protector/encryptImages/blocs/encrypt_bloc.dart';
import 'package:base/datasource/Database.dart';
import 'package:base/datasource/DatabaseImbl.dart';
import 'package:base/encrypt/encryption.dart' as E;

import 'onboardingScreen/OnboardingController.dart';

void injection() {
  // core stuff
  Get.put<E.Encrypt>(E.EncryptImple());

  // datasources
  Get.put<Database>(DatabaseImble());
  Get.put<AuthDataSource>(FirebaseAuthDataSource());

  // usecases
  Get.put(EnnryptImagesUseCase(
      dataScource: Get.find(),
      encrypting: Get.find(),
      authDataSource: Get.find()));
  Get.put(AuthUseCase(authDataSource: Get.find(), encrypt: Get.find()));

  // blocs
  // Get.put(EncryptImagesBloc(useCase: Get.find()));
  // Get.put(AuthBloc(authUseCase: Get.find()));
  Get.put(OnboardingController());
}
