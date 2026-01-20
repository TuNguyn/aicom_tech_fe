import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/tech_user.dart';
import '../../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<Either<Failure, TechUser>> call(
    Map<String, dynamic> data,
  ) async {
    return await repository.updateProfile(data);
  }
}
