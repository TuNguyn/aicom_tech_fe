import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/tech_user.dart';
import '../../repositories/auth_repository.dart';

class GetCachedTech {
  final AuthRepository repository;

  GetCachedTech(this.repository);

  Future<Either<Failure, TechUser?>> call() async {
    return await repository.getCachedUser();
  }
}
