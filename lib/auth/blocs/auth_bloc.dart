import 'package:base/datasource/network/AuthDataSource.dart';
import 'package:base/models/user.dart';
import 'package:data_protector/auth/AuthUseCase.dart';
import 'package:data_protector/auth/blocs/auth_events.dart';
import 'package:data_protector/auth/blocs/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_rx/get_rx.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthUseCase _authUseCase;
  Rx<AuthState> authState = AuthState().obs;
  AuthState previousAuthState;

  AuthBloc({AuthUseCase authUseCase})
      : _authUseCase = authUseCase,
        super(InitAuth());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    print("koko > " + event.props.toString());
    if (event is Login) {
      yield* login(event);
    } else if (event is Signup) {
      print("koko > signup");
      yield* signup(event);
    } else if (event is SetSettings) {
      yield* setSettings(event);
    } else if (event is SetKeyInComplete) {
      yield* setKeyInComplete();
    }
  }

  Stream<AuthState> login(Login event) async* {
    authState.value = Authenticating();
    try {
      var returnedEncKey =
          await _authUseCase.login(event.email, event.password);

      authState.value = LoggedIn(didnotCompleteSignup: returnedEncKey == null);
    } catch (e) {
      authState.value = AuthError(error: e.toString());
    }
  }

  Stream<AuthState> signup(Signup event) async* {
    authState.value = Authenticating();
    try {
      // !! Note : this validation part could be better practise to be in its own class
      // but for simplicity i didn't put into one .
      final validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
      if (event.username.length < 3) {
        throw "user name cann't be so small";
      } else if (event.username.length > 15) {
        throw "user name cann't be so long";
      } else if (!validCharacters.hasMatch(event.username)) {
        throw "user name cann't have a specail characters of white spaces";
      }

      if (!event.email.contains("@")) {
        throw "You cann't write an email without an '@' right ? ";
      }

      await _authUseCase.signup(event.username, event.email, event.password);
      authState.value = SignedUp();
      print("koko > " + authState.value.toString());
    } catch (e) {
      authState.value = AuthError(error: e.toString());
    }
  }

  Stream<AuthState> setSettings(SetSettings event) async* {
    authState.value = AddingSettings();
    try {
      await _authUseCase.setSettings(event.key);
      authState.value = AddedSettings();
    } catch (e) {
      authState.value = AddSettingsError(error: e.toString());
    }
  }

  Stream<AuthState> setKeyInComplete() async* {
    await _authUseCase.deleteUser();
  }

  isLoggedIn() {
    if (_authUseCase.isLoggedIn()) {
      authState.value = LoggedIn(didnotCompleteSignup: false);
      print("koko logged in");
    } else {
      print("koko not logged in ");
    }
  }

  @override
  Future<void> close() {
    authState.close();
    return super.close();
  }
}
