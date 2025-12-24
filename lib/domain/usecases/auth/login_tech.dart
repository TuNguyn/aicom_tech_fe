import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/tech_user.dart';
import '../../repositories/auth_repository.dart';

class LoginTech {
  final AuthRepository repository;

  LoginTech(this.repository);

  Future<Either<Failure, TechUser>> call(
    String username,
    String password,
  ) async {
    return await repository.login(username, password);
  }
}
