import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/tech_user.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/tech_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, TechUser>> login(
    String username,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.login(username, password);
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
            'An unexpected error occurred during login: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, TechUser>> loginWithStore(
    String phone,
    String passCode,
    String storeId,
  ) async {
    try {
      final userModel = await remoteDataSource.loginWithStore(phone, passCode, storeId);
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
            'An unexpected error occurred during login: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
            'An unexpected error occurred during logout: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, TechUser?>> getCachedUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get cached user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final userModel = await remoteDataSource.refreshToken();
      await localDataSource.cacheUser(userModel);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to refresh token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Employee>>> getEmployeeWithPhone(
    String phone,
    String passCode,
  ) async {
    try {
      final employeeModels = await remoteDataSource.getEmployeeWithPhone(phone, passCode);
      final employees = employeeModels.map((model) => model.toEntity()).toList();
      return Right(employees);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          'An unexpected error occurred while verifying employee: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, TechUser>> updateProfile(Map<String, dynamic> data) async {
    try {
      final updatedUserModel = await remoteDataSource.updateProfile(data);
      
      // We need to preserve the token from the current session as the update response might not include it
      final currentUser = await localDataSource.getCachedUser();
      final token = currentUser?.token ?? '';
      
      final userToCache = updatedUserModel.copyWith(token: token);
      
      await localDataSource.cacheUser(userToCache);
      return Right(userToCache);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          'An unexpected error occurred while updating profile: ${e.toString()}',
        ),
      );
    }
  }
}
