import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/ticket_line_model.dart';

abstract class WalkInRepository {
  Future<Either<Failure, TicketLinesResponse>> getWalkInLines({
    List<String>? statuses,
    int page = 1,
    int limit = 100,
    String sortBy = 'displayOrder:ASC',
  });

  Future<Either<Failure, Unit>> startWalkInLine(String lineId);

  Future<Either<Failure, Unit>> completeWalkInLine(String lineId);
}
