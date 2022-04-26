import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/progess_state_dialog/progress_dialog_state.dart';

showProgressDialog(
  BuildContext context,
  Rx<ProgressDialogState> progressDialogState,
  String Function(String) translateErrorCodes, {
  required Function() onDoneAction,
  required Function() closeDialog,
}) {
  showDialog(
      context: context,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async {
            if (progressDialogState.value.success ||
                progressDialogState.value.error.isNotEmpty ||
                progressDialogState.value.progress == 1) {
              return true;
            }
            return false;
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Obx(() {
                var dialogState = progressDialogState.value;
                print("koko dialog state " + dialogState.toString());
                if (dialogState.error.isNotEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(translateErrorCodes(dialogState.error)),
                      const SizedBox(
                        height: 10.0,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            closeDialog();
                          },
                          child: const Text("Okay"))
                    ],
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    dialogState.progress == 0
                        ? const CircularProgressIndicator()
                        : CircularProgressIndicator(
                            value: dialogState.progress),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(dialogState.success
                        ? dialogState.successMessage
                        : dialogState.loadingMessage),
                    if (dialogState.success)
                      ElevatedButton(
                          onPressed: () {
                            closeDialog();
                            onDoneAction();
                            dialogState.actionWhenDone();
                          },
                          child: const Text("Done"))
                  ],
                );
              }),
            ),
          ),
        );
      },
      barrierDismissible: false);
}
