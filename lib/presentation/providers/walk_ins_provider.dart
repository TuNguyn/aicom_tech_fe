import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ticket_line_model.dart';
import '../../domain/entities/walk_in_ticket.dart';
import '../../domain/usecases/walk_ins/get_walk_in_lines.dart';
import '../../domain/usecases/walk_ins/start_walk_in_line.dart';
import '../../domain/usecases/walk_ins/complete_walk_in_line.dart';

// Display model
class ServiceLineDisplay extends Equatable {
  final String customerName;
  final WalkInServiceLine serviceLine;
  final DateTime createdAt;

  const ServiceLineDisplay({
    required this.customerName,
    required this.serviceLine,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [customerName, serviceLine, createdAt];
}

class WalkInsState extends Equatable {
  final List<WalkInTicket> walkInTickets;
  final AsyncValue<void> loadingStatus;
  double get totalTurn {
    // Tự động tính tổng dựa trên danh sách hiện tại
    return walkInTickets.fold(0.0, (sum, ticket) => sum + ticket.turnValue);
  }

  const WalkInsState({
    this.walkInTickets = const [],
    this.loadingStatus = const AsyncValue.data(null),
  });

  // Helper để lấy tất cả line từ các ticket
  List<ServiceLineDisplay> _flatMapServiceLines({
    bool includeCancelled = false,
  }) {
    final lines = <ServiceLineDisplay>[];
    for (final ticket in walkInTickets) {
      for (final serviceLine in ticket.serviceLines) {
        if (serviceLine.itemType != 'SERVICE') continue;

        if (!includeCancelled &&
            serviceLine.status == WalkInLineStatus.canceled) {
          continue;
        }

        lines.add(
          ServiceLineDisplay(
            customerName: ticket.customerName,
            serviceLine: serviceLine,
            createdAt: ticket.createdAt,
          ),
        );
      }
    }
    return lines;
  }

  // Getter chính dùng cho UI
  List<ServiceLineDisplay> get sortedServiceLines {
    final lines = _flatMapServiceLines(includeCancelled: false);

    // Sort logic
    lines.sort(
      (a, b) => _compareByStatus(
        a.serviceLine.status,
        b.serviceLine.status,
        a.createdAt,
        b.createdAt,
      ),
    );
    return lines;
  }

  int get activeTicketsCount {
    return walkInTickets.where((ticket) {
      return ticket.serviceLines.any(
        (line) =>
            line.status == WalkInLineStatus.waiting ||
            line.status == WalkInLineStatus.serving,
      );
    }).length;
  }

  // Getter dùng cho Summary (nếu cần lấy cả canceled)
  List<ServiceLineDisplay> get allServiceLines {
    return _flatMapServiceLines(includeCancelled: true);
  }

  static int _compareByStatus(
    WalkInLineStatus statusA,
    WalkInLineStatus statusB,
    DateTime createdAtA,
    DateTime createdAtB,
  ) {
    // 1. Waiting lên đầu
    if (statusA == WalkInLineStatus.waiting &&
        statusB != WalkInLineStatus.waiting) {
      return -1;
    }
    if (statusA != WalkInLineStatus.waiting &&
        statusB == WalkInLineStatus.waiting) {
      return 1;
    }
    // 2. Serving thứ hai
    if (statusA == WalkInLineStatus.serving &&
        statusB != WalkInLineStatus.serving) {
      return -1;
    }
    if (statusA != WalkInLineStatus.serving &&
        statusB == WalkInLineStatus.serving) {
      return 1;
    }

    // 3. Cuối cùng sort theo thời gian (Mới nhất lên trên)
    return createdAtB.compareTo(createdAtA);
  }

  WalkInsState copyWith({
    List<WalkInTicket>? walkInTickets,
    AsyncValue<void>? loadingStatus,
  }) {
    return WalkInsState(
      walkInTickets: walkInTickets ?? this.walkInTickets,
      loadingStatus: loadingStatus ?? this.loadingStatus,
    );
  }

  @override
  List<Object?> get props => [walkInTickets, loadingStatus, totalTurn];
}

class WalkInsNotifier extends StateNotifier<WalkInsState> {
  final GetWalkInLines _getWalkInLines;
  final StartWalkInLine _startWalkInLine;
  final CompleteWalkInLine _completeWalkInLine;

  WalkInsNotifier(
    this._getWalkInLines,
    this._startWalkInLine,
    this._completeWalkInLine,
  ) : super(const WalkInsState());

  Future<void> loadWalkIns({List<String>? statuses}) async {
    if (state.loadingStatus.isLoading) return;

    state = state.copyWith(loadingStatus: const AsyncValue.loading());

    final result = await _getWalkInLines(
      statuses: statuses ?? ['WAITING', 'SERVING', 'DONE', 'CANCELLED'],
    );

    result.fold(
      (failure) => state = state.copyWith(
        loadingStatus: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (response) {
        final tickets = _groupTicketLines(response.data);
        state = state.copyWith(
          walkInTickets: tickets,
          loadingStatus: const AsyncValue.data(null),
        );
      },
    );
  }

  List<WalkInTicket> _groupTicketLines(List<TicketLineModel> lines) {
    // Group by ticket ID
    final ticketsMap = <String, List<TicketLineModel>>{};
    for (final line in lines) {
      ticketsMap.putIfAbsent(line.ticket.id, () => []).add(line);
    }

    return ticketsMap.entries.map((entry) {
      final lines = entry.value;
      final firstLine = lines.first;

      lines.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      // [CẬP NHẬT] Chỉ cộng turnValue nếu trạng thái là DONE
      final ticketTurnValue = lines.fold<double>(0.0, (sum, line) {
        // Kiểm tra status (API trả về String 'DONE', 'WAITING'...)
        if (line.status == 'DONE') {
          return sum + line.turnValue;
        }
        return sum;
      });

      return WalkInTicket(
        ticketId: firstLine.ticket.id,
        ticketCode: firstLine.ticket.ticketCode,
        customerName: firstLine.ticket.customer?.fullName ?? 'Visitor',
        customerId: firstLine.ticket.customer?.id ?? '',
        serviceLines: lines.map((line) => line.toEntity()).toList(),
        createdAt: firstLine.ticket.createdAt,
        updatedAt: firstLine.ticket.updatedAt,
        notes: firstLine.ticket.note,
        totalPrice: firstLine.ticket.totalPrice,
        totalTips: firstLine.ticket.totalTips,
        totalDiscount: firstLine.ticket.totalDiscount,
        totalTax: firstLine.ticket.totalTax,
        totalPaid: firstLine.ticket.totalPaid,
        turnValue: ticketTurnValue,
      );
    }).toList();
  }

  Future<void> refreshWalkIns() async {
    await loadWalkIns();
  }

  void reset() {
    state = const WalkInsState();
  }

  // --- SOCKET UPDATE LOGIC ---

  void onTicketReceived(WalkInTicket incomingTicket) {
    // nhận vé và xử lý

    final currentList = List<WalkInTicket>.from(state.walkInTickets);

    // Tìm và xóa vé cũ (nếu có) để cập nhật
    currentList.removeWhere((t) => t.ticketId == incomingTicket.ticketId);

    // Thêm vé mới
    currentList.add(incomingTicket);

    // Update State
    state = state.copyWith(walkInTickets: currentList);
  }

  void removeTicket(String ticketId) {
    final currentList = List<WalkInTicket>.from(state.walkInTickets);
    final initialLength = currentList.length;

    currentList.removeWhere((t) => t.ticketId == ticketId);

    if (currentList.length != initialLength) {
      state = state.copyWith(walkInTickets: currentList);
    }
  }

  // --- ACTIONS ---

  Future<String?> startServiceLine(String lineId) async {
    final result = await _startWalkInLine(lineId);
    if (result.isRight()) {
      await refreshWalkIns();
      return null;
    }
    return result.fold((failure) => failure.message, (_) => null);
  }

  Future<String?> completeServiceLine(String lineId) async {
    final result = await _completeWalkInLine(lineId);
    if (result.isRight()) {
      await refreshWalkIns();
      return null;
    }
    return result.fold((failure) => failure.message, (_) => null);
  }
}
