import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/appointment_lines_repository.dart';
import '../../domain/entities/appointment_line.dart';
import '../datasources/appointment_remote_data_source.dart';

class AppointmentLinesRepositoryImpl implements AppointmentLinesRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentLinesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<AppointmentLine>>> getAppointmentLines({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 10,
    String sortBy = 'beginTime:ASC',
  }) async {
    try {
      final response = await remoteDataSource.getAppointmentLines(
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
        sortBy: sortBy,
      );

      final entities = response.data.map((model) => model.toEntity()).toList();

      return Right(entities);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          'An unexpected error occurred while fetching appointments: ${e.toString()}',
        ),
      );
    }
  }
}
