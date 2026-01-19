import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/walk_in_repository.dart';
import '../datasources/walk_in_remote_data_source.dart';
import '../models/ticket_line_model.dart';

class WalkInRepositoryImpl implements WalkInRepository {
  final WalkInRemoteDataSource remoteDataSource;

  WalkInRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, TicketLinesResponse>> getWalkInLines({
    List<String>? statuses,
    int page = 1,
    int limit = 100,
    String sortBy = 'displayOrder:ASC',
  }) async {
    try {
      final response = await remoteDataSource.getWalkInLines(
        statuses: statuses,
        page: page,
        limit: limit,
        sortBy: sortBy,
      );
      return Right(response);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          'An unexpected error occurred while fetching walk-ins: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> startWalkInLine(String lineId) async {
    try {
      await remoteDataSource.startWalkInLine(lineId);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to start service: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeWalkInLine(String lineId) async {
    try {
      await remoteDataSource.completeWalkInLine(lineId);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to complete service: ${e.toString()}'));
    }
  }
}
