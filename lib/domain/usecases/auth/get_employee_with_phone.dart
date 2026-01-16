import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/employee.dart';
import '../../repositories/auth_repository.dart';

class GetEmployeeWithPhone {
  final AuthRepository repository;

  GetEmployeeWithPhone(this.repository);

  Future<Either<Failure, List<Employee>>> call(
    String phone,
    String passCode,
  ) async {
    return await repository.getEmployeeWithPhone(phone, passCode);
  }
}
