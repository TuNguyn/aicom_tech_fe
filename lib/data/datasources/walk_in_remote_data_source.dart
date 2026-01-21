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
      print('[WalkInDataSource] ========================================');
      print('[WalkInDataSource] Calling API: /employee-app/tickets/lines');
      print('[WalkInDataSource] Parameters:');
      print('[WalkInDataSource]   page: $page');
      print('[WalkInDataSource]   limit: $limit');
      print('[WalkInDataSource]   sortBy: $sortBy');
      print('[WalkInDataSource]   statuses: $statuses');

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

      print('[WalkInDataSource] ✅ API response received');
      print('[WalkInDataSource] Response data type: ${response.data?.runtimeType}');
      print('[WalkInDataSource] ========================================');

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
    print('[WalkInDataSource] ========================================');
    print('[WalkInDataSource] START Service Line');
    print('[WalkInDataSource] Line ID: $lineId');
    print('[WalkInDataSource] Calling API: PATCH /employee-app/tickets/lines/$lineId/start');

    final response = await dioClient.patch('/employee-app/tickets/lines/$lineId/start');

    print('[WalkInDataSource] ✅ START API response:');
    print('[WalkInDataSource] Response: $response');
    print('[WalkInDataSource] ========================================');
  }

  @override
  Future<void> completeWalkInLine(String lineId) async {
    print('[WalkInDataSource] ========================================');
    print('[WalkInDataSource] COMPLETE Service Line');
    print('[WalkInDataSource] Line ID: $lineId');
    print('[WalkInDataSource] Calling API: PATCH /employee-app/tickets/lines/$lineId/done');

    final response = await dioClient.patch('/employee-app/tickets/lines/$lineId/done');

    print('[WalkInDataSource] ✅ COMPLETE API response:');
    print('[WalkInDataSource] Response: $response');
    print('[WalkInDataSource] ========================================');
  }
}
