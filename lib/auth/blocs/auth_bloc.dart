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
    }
  }

  Stream<AuthState> login(Login event) async* {
    authState.value = Authenticating();
    try {
      await _authUseCase.login(event.email, event.password);
      authState.value = LoggedIn();
    } catch (e) {
      authState.value = AuthError(error: e.toString());
    }
  }

  Stream<AuthState> signup(Signup event) async* {
    authState.value = Authenticating();
    try {
      await _authUseCase.signup(event.username, event.email, event.password);
      authState.value = SignedUp();
      print("koko > "+authState.value.toString());
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

  isLoggedIn(){
    if (_authUseCase.isLoggedIn()){
      authState.value = LoggedIn();
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
