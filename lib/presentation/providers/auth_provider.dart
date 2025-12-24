import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/tech_user.dart';
import '../../domain/usecases/auth/login_tech.dart';
import '../../domain/usecases/auth/logout_tech.dart';
import '../../domain/usecases/auth/get_cached_tech.dart';

class AuthState {
  final TechUser user;
  final AsyncValue<void> loginStatus;
  final AsyncValue<void> logoutStatus;

  bool get isAuthenticated => user.isAuthenticated;

  AuthState({
    required this.user,
    this.loginStatus = const AsyncValue.data(null),
    this.logoutStatus = const AsyncValue.data(null),
  });

  AuthState copyWith({
    TechUser? user,
    AsyncValue<void>? loginStatus,
    AsyncValue<void>? logoutStatus,
  }) {
    return AuthState(
      user: user ?? this.user,
      loginStatus: loginStatus ?? this.loginStatus,
      logoutStatus: logoutStatus ?? this.logoutStatus,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginTech _loginTech;
  final LogoutTech _logoutTech;
  final GetCachedTech _getCachedTech;

  AuthNotifier(
    this._loginTech,
    this._logoutTech,
    this._getCachedTech,
  ) : super(AuthState(user: TechUser.empty)) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final result = await _getCachedTech();
    result.fold(
      (_) => null,
      (user) {
        if (user != null) {
          state = state.copyWith(user: user);
        }
      },
    );
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(loginStatus: const AsyncValue.loading());
    final result = await _loginTech(username, password);

    state = result.fold(
      (failure) => state.copyWith(
        loginStatus: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (user) => state.copyWith(
        user: user,
        loginStatus: const AsyncValue.data(null),
      ),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(logoutStatus: const AsyncValue.loading());
    final result = await _logoutTech();

    state = result.fold(
      (failure) => state.copyWith(
        logoutStatus: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (_) => state.copyWith(
        user: TechUser.empty,
        logoutStatus: const AsyncValue.data(null),
      ),
    );
  }
}
