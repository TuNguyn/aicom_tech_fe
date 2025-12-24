import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/tech_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, TechUser>> login(String username, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, TechUser?>> getCachedUser();
  Future<Either<Failure, void>> refreshToken();
}
