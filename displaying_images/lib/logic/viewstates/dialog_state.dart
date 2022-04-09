class DialogState {
  final bool loading;
  final String error;
  final bool isDone;
  final String doneMessage;

  DialogState(
      {required this.loading,
      required this.doneMessage,
      required this.error,
      required this.isDone});

  factory DialogState.init() {
    return DialogState(
        loading: false, error: "", doneMessage: "", isDone: false);
  }

  DialogState copy(
      {bool? loading, String? doneMessage, String? error, bool? isDone}) {
    return DialogState(
        loading: loading ?? this.loading,
        error: error ?? this.error,
        doneMessage: doneMessage ?? this.doneMessage,
        isDone: isDone ?? this.isDone);
  }
}
