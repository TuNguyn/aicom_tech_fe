import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/tech_user.dart';
import '../../repositories/auth_repository.dart';

class LoginWithStore {
  final AuthRepository repository;

  LoginWithStore(this.repository);

  Future<Either<Failure, TechUser>> call(
    String phone,
    String passCode,
    String storeId,
  ) async {
    return await repository.loginWithStore(phone, passCode, storeId);
  }
}
