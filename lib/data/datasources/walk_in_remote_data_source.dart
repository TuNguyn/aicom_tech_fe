import '../../core/network/dio_client.dart';
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
    final response = await dioClient.get(
      '/employee-app/tickets/lines',
      queryParameters: {
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        if (statuses != null && statuses.isNotEmpty) 'statuses': statuses.join(','),
      },
    );
    return TicketLinesResponse.fromJson(response.data);
  }

  @override
  Future<void> startWalkInLine(String lineId) async {
    await dioClient.patch('/employee-app/tickets/lines/$lineId/start');
  }

  @override
  Future<void> completeWalkInLine(String lineId) async {
    await dioClient.patch('/employee-app/tickets/lines/$lineId/done');
  }
}
