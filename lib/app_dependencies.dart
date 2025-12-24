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
import 'domain/usecases/auth/logout_tech.dart';
import 'domain/usecases/auth/get_cached_tech.dart';
import 'presentation/providers/auth_provider.dart';

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

// StateNotifier providers
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(loginTechUseCaseProvider),
    ref.read(logoutTechUseCaseProvider),
    ref.read(getCachedTechUseCaseProvider),
  );
});
