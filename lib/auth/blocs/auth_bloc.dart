import 'package:base/datasource/network/AuthDataSource.dart';
import 'package:base/models/user.dart';
import 'package:data_protector/auth/AuthUseCase.dart';
import 'package:data_protector/auth/blocs/auth_events.dart';
import 'package:data_protector/auth/blocs/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_rx/get_rx.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthUseCase _authUseCase;
  Rx<AuthState> authState = InitAuth().obs;

  AuthBloc({AuthUseCase authUseCase})
      : _authUseCase = authUseCase,
        super(InitAuth());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is Login) {
      yield* login(event);
    } else if (event is Signup) {
      yield* signup(event);
    } else if (event is SetSettings) {
      yield* setSettings(event);
    }
  }

  Stream<AuthState> login(Login event) async* {
    authState = Authenticating().obs;
    try {
      await _authUseCase.login(event.email, event.password);
      authState = LoggedIn().obs;
    } catch (e) {
      authState = AuthError(error: e.toString()).obs;
    }
  }

  Stream<AuthState> signup(Signup event) async* {
    authState = Authenticating().obs;
    try {
      await _authUseCase.signup(event.username, event.email, event.password);
      authState = SignedUp().obs;
    } catch (e) {
      authState = AuthError(error: e.toString()).obs;
    }
  }

  Stream<AuthState> setSettings(SetSettings event) async* {
    authState = AddingSettings().obs;
    try {
      await _authUseCase.setSettings(event.key);
      authState = AddedSettings().obs;
    } catch (e) {
      authState = AddSettingsError(error: e.toString()).obs;
    }
  }

  @override
  Future<void> close() {
    authState.close();
    return super.close();
  }
}
