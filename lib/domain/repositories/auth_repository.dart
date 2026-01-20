import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/tech_user.dart';
import '../entities/employee.dart';

abstract class AuthRepository {
  Future<Either<Failure, TechUser>> loginWithStore(String phone, String passCode, String storeId);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, TechUser?>> getCachedUser();
  Future<Either<Failure, List<Employee>>> getEmployeeWithPhone(String phone, String passCode);
  Future<Either<Failure, TechUser>> updateProfile(Map<String, dynamic> data);
}
