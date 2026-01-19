import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/ticket_line_model.dart';
import '../../repositories/walk_in_repository.dart';

class GetWalkInLines {
  final WalkInRepository repository;

  GetWalkInLines(this.repository);

  Future<Either<Failure, TicketLinesResponse>> call({
    List<String>? statuses,
    int page = 1,
    int limit = 100,
    String sortBy = 'displayOrder:ASC',
  }) async {
    return await repository.getWalkInLines(
      statuses: statuses,
      page: page,
      limit: limit,
      sortBy: sortBy,
    );
  }
}
