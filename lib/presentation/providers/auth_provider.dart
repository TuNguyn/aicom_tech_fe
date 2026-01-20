import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/tech_user.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/auth/login_tech.dart';
import '../../domain/usecases/auth/login_with_store.dart';
import '../../domain/usecases/auth/logout_tech.dart';
import '../../domain/usecases/auth/get_cached_tech.dart';
import '../../domain/usecases/auth/get_employee_with_phone.dart';
import '../../domain/usecases/auth/update_profile.dart';

class AuthState {
  final TechUser user;
  final AsyncValue<void> loginStatus;
  final AsyncValue<void> logoutStatus;
  final AsyncValue<void> verifyStatus;
  final AsyncValue<void> updateProfileStatus;
  final List<Employee> verifiedEmployees;
  final String? pendingPhone;
  final String? pendingPassCode;

  bool get isAuthenticated => user.isAuthenticated;

  AuthState({
    required this.user,
    this.loginStatus = const AsyncValue.data(null),
    this.logoutStatus = const AsyncValue.data(null),
    this.verifyStatus = const AsyncValue.data(null),
    this.updateProfileStatus = const AsyncValue.data(null),
    this.verifiedEmployees = const [],
    this.pendingPhone,
    this.pendingPassCode,
  });

  AuthState copyWith({
    TechUser? user,
    AsyncValue<void>? loginStatus,
    AsyncValue<void>? logoutStatus,
    AsyncValue<void>? verifyStatus,
    AsyncValue<void>? updateProfileStatus,
    List<Employee>? verifiedEmployees,
    String? pendingPhone,
    String? pendingPassCode,
    bool clearPendingCredentials = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      loginStatus: loginStatus ?? this.loginStatus,
      logoutStatus: logoutStatus ?? this.logoutStatus,
      verifyStatus: verifyStatus ?? this.verifyStatus,
      updateProfileStatus: updateProfileStatus ?? this.updateProfileStatus,
      verifiedEmployees: verifiedEmployees ?? this.verifiedEmployees,
      pendingPhone: clearPendingCredentials ? null : (pendingPhone ?? this.pendingPhone),
      pendingPassCode: clearPendingCredentials ? null : (pendingPassCode ?? this.pendingPassCode),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginTech _loginTech;
  final LoginWithStore _loginWithStore;
  final LogoutTech _logoutTech;
  final GetCachedTech _getCachedTech;
  final GetEmployeeWithPhone _getEmployeeWithPhone;
  final UpdateProfile _updateProfile;

  AuthNotifier(
    this._loginTech,
    this._loginWithStore,
    this._logoutTech,
    this._getCachedTech,
    this._getEmployeeWithPhone,
    this._updateProfile,
  ) : super(AuthState(user: TechUser.empty)) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final result = await _getCachedTech();
    result.fold(
      (failure) {},
      (user) {
        if (user != null) {
          state = state.copyWith(user: user);
        }
      },
    );
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(updateProfileStatus: const AsyncValue.loading());
    final result = await _updateProfile(state.user.id, data);

    result.fold(
      (failure) {
        state = state.copyWith(
          updateProfileStatus: AsyncValue.error(failure.message, StackTrace.current),
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          updateProfileStatus: const AsyncValue.data(null),
        );
      },
    );
  }

  Future<void> verifyEmployee(String phone, String passCode) async {
    state = state.copyWith(
      verifyStatus: const AsyncValue.loading(),
      pendingPhone: phone,
      pendingPassCode: passCode,
    );

    final result = await _getEmployeeWithPhone(phone, passCode);

    result.fold(
      (failure) {
        state = state.copyWith(
          verifyStatus: AsyncValue.error(failure.message, StackTrace.current),
          clearPendingCredentials: true,
        );
      },
      (employees) {
        state = state.copyWith(
          verifiedEmployees: employees,
          verifyStatus: const AsyncValue.data(null),
        );
      },
    );
  }

  Future<void> loginWithStore(String storeId) async {
    final phone = state.pendingPhone;
    final passCode = state.pendingPassCode;

    if (phone == null || passCode == null) {
      state = state.copyWith(
        loginStatus: AsyncValue.error('Missing credentials', StackTrace.current),
      );
      return;
    }

    state = state.copyWith(loginStatus: const AsyncValue.loading());
    final result = await _loginWithStore(phone, passCode, storeId);

    result.fold(
      (failure) {
        state = state.copyWith(
          loginStatus: AsyncValue.error(failure.message, StackTrace.current),
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          loginStatus: const AsyncValue.data(null),
          verifiedEmployees: [],
          clearPendingCredentials: true,
        );
      },
    );
  }

  void clearVerifiedEmployees() {
    state = state.copyWith(
      verifiedEmployees: [],
      clearPendingCredentials: true,
    );
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(loginStatus: const AsyncValue.loading());
    final result = await _loginTech(username, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          loginStatus: AsyncValue.error(failure.message, StackTrace.current),
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          loginStatus: const AsyncValue.data(null),
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(logoutStatus: const AsyncValue.loading());
    final result = await _logoutTech();

    result.fold(
      (failure) {
        state = state.copyWith(
          logoutStatus: AsyncValue.error(failure.message, StackTrace.current),
        );
      },
      (_) {
        state = state.copyWith(
          user: TechUser.empty,
          logoutStatus: const AsyncValue.data(null),
        );
      },
    );
  }
}
