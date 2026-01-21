import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/tech_user.dart';
import '../../repositories/auth_repository.dart';

class GetEmployeeProfile {
  final AuthRepository repository;

  GetEmployeeProfile(this.repository);

  Future<Either<Failure, TechUser>> call() async {
    return await repository.getEmployeeProfile();
  }
}
