// ignore_for_file: avoid_print

import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/ticket_line_model.dart';

abstract class WalkInRemoteDataSource {
  Future<TicketLinesResponse> getWalkInLines({
    List<String>? statuses,
    int page = 1,
    int limit = 100,
    String sortBy = 'displayOrder:ASC',
  });

  Future<void> startWalkInLine(String lineId);

  Future<void> completeWalkInLine(String lineId);
}

class WalkInRemoteDataSourceImpl implements WalkInRemoteDataSource {
  final DioClient dioClient;

  WalkInRemoteDataSourceImpl(this.dioClient);

  @override
  Future<TicketLinesResponse> getWalkInLines({
    List<String>? statuses,
    int page = 1,
    int limit = 100,
    String sortBy = 'displayOrder:ASC',
  }) async {
    try {
      final response = await dioClient.get(
        '/employee-app/tickets/lines',
        queryParameters: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          if (statuses != null && statuses.isNotEmpty)
            'statuses': statuses.join(','),
        },
      );

      if (response.data == null) {
        throw ServerException(message: 'No data received from server');
      }

      if (response.data is! Map<String, dynamic>) {
        throw ServerException(message: 'Invalid response format');
      }

      return TicketLinesResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch walk-ins: $e');
    }
  }

  @override
  Future<void> startWalkInLine(String lineId) async {
    print('[API] START line: $lineId');
    await dioClient.patch('/employee-app/tickets/lines/$lineId/start');
  }

  @override
  Future<void> completeWalkInLine(String lineId) async {
    print('[API] COMPLETE line: $lineId');
    await dioClient.patch('/employee-app/tickets/lines/$lineId/done');
  }
}
