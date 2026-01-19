import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/walk_in_repository.dart';

class CompleteWalkInLine {
  final WalkInRepository repository;

  CompleteWalkInLine(this.repository);

  Future<Either<Failure, Unit>> call(String lineId) async {
    return await repository.completeWalkInLine(lineId);
  }
}
