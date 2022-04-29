import 'package:base/datasource/File.dart';
import 'package:base/datasource/network/AuthDataSource.dart';
import 'package:base/datasource/network/FirebaseAuthDataSource.dart';
import 'package:data_protector/auth/AuthUseCase.dart';
import 'package:data_protector/auth/blocs/auth_bloc.dart';
import 'package:data_protector/data/adapters/user_adapter.dart';
import 'package:data_protector/data/displaying_images/displaying_images_datasource_imp.dart';
import 'package:data_protector/data/share_images/share_images_datasource_imp.dart';
import 'package:data_protector/data/user/user_supplier.dart';
import 'package:data_protector/data/user/user_supplier_imp.dart';
import 'package:displaying_images/logic/datasource.dart';
import 'package:displaying_images/logic/usecase.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:share_images/logic/datasource.dart';
import 'encryptImages/encrypt_images_use_case.dart';

import 'package:data_protector/encryptImages/blocs/encrypt_bloc.dart';
import 'package:base/datasource/Database.dart';
import 'package:base/datasource/DatabaseImbl.dart';
import 'package:base/encrypt/encryption.dart' as E;

import 'onboardingScreen/OnboardingController.dart';

void injection() {
  // core stuff
  Get.put<E.Encrypt>(E.EncryptImple());

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(FileAdapter());
  }

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserAdapter());
  }

  // datasources
  // Get.put<Database>(DatabaseImble());
  // Get.put<AuthDataSource>(FirebaseAuthDataSource());
  //
  // // usecases
  // Get.put(EnnryptImagesUseCase(
  //     dataScource: Get.find(),
  //     encrypting: Get.find(),
  //     authDataSource: Get.find()));
  // Get.put(AuthUseCase(authDataSource: Get.find(), encrypt: Get.find()));
  //
  // // blocs
  // // Get.put(EncryptImagesBloc(useCase: Get.find()));
  // // Get.put(AuthBloc(authUseCase: Get.find()));
  // Get.put(OnboardingController());
  Get.put<UserSupplier>(UserSupplierImp());
  Get.put<DisplayingImagesDataSource>(
      DisplayingImagesDataSourceImp(Get.find()));
  Get.put(DisplayingImagesUseCase(Get.find(), Get.find()));
  Get.put<ShareImagesDataSource>(ShareImagesDataSourceImp());
}
