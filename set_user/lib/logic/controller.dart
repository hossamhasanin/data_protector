import 'package:get/get.dart';
import 'package:set_user/logic/datasource.dart';

class SetUserController extends GetxController {

  late final Function(bool isLoading) _showLoadingDialog;
  late final Function() _showErrorDialog;
  late final Function() _onSetUserSuccess;

  final SetUserDataSource _dataSource;


  SetUserController(this._dataSource, {required Function(bool isLoading) showLoadingDialog, required Function() showErrorDialog, required Function() onSetUserSuccess}){
    _showLoadingDialog = showLoadingDialog;
    _showErrorDialog = showErrorDialog;
    _onSetUserSuccess = onSetUserSuccess;
  }

   Future hasDataSet() async {
    _showLoadingDialog(true);
    final result = await _dataSource.hasDataSet();
    _showLoadingDialog(false);

    if (result){
      _onSetUserSuccess();
    }
  }

  void setUser(String username,  String secretKey) async {
    _showLoadingDialog(true);

    final result = await _dataSource.setUser(username, secretKey);

    _showLoadingDialog(false);

    if (result) {
      _onSetUserSuccess();
    } else {
      _showErrorDialog();
    }
  }
}