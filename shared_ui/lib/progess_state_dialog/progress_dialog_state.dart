
class ProgressDialogState {
  final bool loading;
  final double progress;
  final String error;
  final bool success;
  final String successMessage;
  final String loadingMessage;
  final Function() actionWhenDone;

  ProgressDialogState({
    required this.loading,
    required this.success,
    required this.progress,
    required this.loadingMessage,
    required this.error,
    required this.successMessage,
    required this.actionWhenDone,
  });

  factory ProgressDialogState.initial() {
    return ProgressDialogState(
        loading: false,
        progress: 0,
        success: false,
        error: '',
        successMessage: '',
        loadingMessage: "",
        actionWhenDone: () {});
  }

  // copy constructor
  ProgressDialogState copy({
    bool? loading,
    double? progress,
    String? error,
    bool? success,
    String? successMessage,
    String? loadingMessage,
    Function()? actionWhenDone,
  }) {
    return ProgressDialogState(
      loading: loading ?? this.loading,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      success: success ?? this.success,
      successMessage: successMessage ?? this.successMessage,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      actionWhenDone: actionWhenDone ?? this.actionWhenDone,
    );
  }
}
