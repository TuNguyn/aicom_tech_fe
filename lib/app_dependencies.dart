import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'core/constants/app_constants.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/local_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth/login_tech.dart';
import 'domain/usecases/auth/login_with_store.dart';
import 'domain/usecases/auth/logout_tech.dart';
import 'domain/usecases/auth/get_cached_tech.dart';
import 'domain/usecases/auth/get_employee_with_phone.dart';
import 'domain/usecases/appointments/get_appointment_lines.dart';
import 'domain/repositories/appointment_lines_repository.dart';
import 'data/datasources/appointment_remote_data_source.dart';
import 'data/repositories/appointment_lines_repository_impl.dart';
import 'domain/usecases/walk_ins/get_walk_in_lines.dart';
import 'domain/usecases/walk_ins/start_walk_in_line.dart';
import 'domain/usecases/walk_ins/complete_walk_in_line.dart';
import 'domain/repositories/walk_in_repository.dart';
import 'data/datasources/walk_in_remote_data_source.dart';
import 'data/repositories/walk_in_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/appointments_provider.dart';
import 'presentation/providers/walk_ins_provider.dart';

// Core providers
final dioProvider = Provider<Dio>((ref) => Dio());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.read(dioProvider));
});

// Hive box providers
final authBoxProvider = Provider<Box<dynamic>>((ref) {
  if (!Hive.isBoxOpen(AppConstants.authBoxName)) {
    throw Exception('Auth box not open');
  }
  return Hive.box<dynamic>(AppConstants.authBoxName);
});

// Data source providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.read(dioClientProvider));
});

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSourceImpl(ref.read(authBoxProvider));
});

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(localDataSourceProvider),
  );
});

// Use case providers
final loginTechUseCaseProvider = Provider<LoginTech>((ref) {
  return LoginTech(ref.read(authRepositoryProvider));
});

final logoutTechUseCaseProvider = Provider<LogoutTech>((ref) {
  return LogoutTech(ref.read(authRepositoryProvider));
});

final getCachedTechUseCaseProvider = Provider<GetCachedTech>((ref) {
  return GetCachedTech(ref.read(authRepositoryProvider));
});

final getEmployeeWithPhoneUseCaseProvider = Provider<GetEmployeeWithPhone>((ref) {
  return GetEmployeeWithPhone(ref.read(authRepositoryProvider));
});

final loginWithStoreUseCaseProvider = Provider<LoginWithStore>((ref) {
  return LoginWithStore(ref.read(authRepositoryProvider));
});

// StateNotifier providers
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(loginTechUseCaseProvider),
    ref.read(loginWithStoreUseCaseProvider),
    ref.read(logoutTechUseCaseProvider),
    ref.read(getCachedTechUseCaseProvider),
    ref.read(getEmployeeWithPhoneUseCaseProvider),
  );
});

// Appointment providers
final appointmentRemoteDataSourceProvider = Provider<AppointmentRemoteDataSource>((ref) {
  return AppointmentRemoteDataSourceImpl(ref.read(dioClientProvider));
});

final appointmentLinesRepositoryProvider = Provider<AppointmentLinesRepository>((ref) {
  return AppointmentLinesRepositoryImpl(ref.read(appointmentRemoteDataSourceProvider));
});

final getAppointmentLinesUseCaseProvider = Provider<GetAppointmentLines>((ref) {
  return GetAppointmentLines(ref.read(appointmentLinesRepositoryProvider));
});

final appointmentsNotifierProvider =
    StateNotifierProvider<AppointmentsNotifier, AppointmentsState>((ref) {
  return AppointmentsNotifier(ref.read(getAppointmentLinesUseCaseProvider));
});

// Walk-in providers
final walkInRemoteDataSourceProvider = Provider<WalkInRemoteDataSource>((ref) {
  return WalkInRemoteDataSourceImpl(ref.read(dioClientProvider));
});

final walkInRepositoryProvider = Provider<WalkInRepository>((ref) {
  return WalkInRepositoryImpl(ref.read(walkInRemoteDataSourceProvider));
});

final getWalkInLinesUseCaseProvider = Provider<GetWalkInLines>((ref) {
  return GetWalkInLines(ref.read(walkInRepositoryProvider));
});

final startWalkInLineUseCaseProvider = Provider<StartWalkInLine>((ref) {
  return StartWalkInLine(ref.read(walkInRepositoryProvider));
});

final completeWalkInLineUseCaseProvider = Provider<CompleteWalkInLine>((ref) {
  return CompleteWalkInLine(ref.read(walkInRepositoryProvider));
});

final walkInsNotifierProvider =
    StateNotifierProvider<WalkInsNotifier, WalkInsState>((ref) {
  return WalkInsNotifier(
    ref.read(getWalkInLinesUseCaseProvider),
    ref.read(startWalkInLineUseCaseProvider),
    ref.read(completeWalkInLineUseCaseProvider),
  );
});
