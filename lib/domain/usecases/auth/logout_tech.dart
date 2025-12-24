import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

class LogoutTech {
  final AuthRepository repository;

  LogoutTech(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
