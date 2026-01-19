import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ticket_line_model.dart';
import '../../domain/entities/walk_in_ticket.dart';
import '../../domain/usecases/walk_ins/get_walk_in_lines.dart';

class WalkInsState extends Equatable {
  final List<WalkInTicket> walkInTickets;
  final AsyncValue<void> loadingStatus;

  const WalkInsState({
    this.walkInTickets = const [],
    this.loadingStatus = const AsyncValue.data(null),
  });

  List<WalkInTicket> get sortedTickets {
    final tickets = List<WalkInTicket>.from(walkInTickets);
    tickets.sort((a, b) {
      // Waiting status first, then serving, then done
      if (a.overallStatus == WalkInLineStatus.waiting &&
          b.overallStatus != WalkInLineStatus.waiting) {
        return -1;
      }
      if (a.overallStatus != WalkInLineStatus.waiting &&
          b.overallStatus == WalkInLineStatus.waiting) {
        return 1;
      }
      if (a.overallStatus == WalkInLineStatus.serving &&
          b.overallStatus != WalkInLineStatus.serving &&
          b.overallStatus != WalkInLineStatus.waiting) {
        return -1;
      }
      if (a.overallStatus != WalkInLineStatus.serving &&
          a.overallStatus != WalkInLineStatus.waiting &&
          b.overallStatus == WalkInLineStatus.serving) {
        return 1;
      }
      // Then by creation time (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
    return tickets;
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
  List<Object?> get props => [walkInTickets, loadingStatus];
}

class WalkInsNotifier extends StateNotifier<WalkInsState> {
  final GetWalkInLines _getWalkInLines;

  WalkInsNotifier(this._getWalkInLines) : super(const WalkInsState());

  Future<void> loadWalkIns({List<String>? statuses}) async {
    state = state.copyWith(loadingStatus: const AsyncValue.loading());

    final result = await _getWalkInLines(
      statuses: statuses ?? ['WAITING', 'SERVING', 'DONE'],
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          loadingStatus: AsyncValue.error(failure.message, StackTrace.current),
        );
      },
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

    // Transform to WalkInTicket entities
    return ticketsMap.entries.map((entry) {
      final lines = entry.value;
      final firstLine = lines.first;

      return WalkInTicket(
        ticketId: firstLine.ticket.id,
        ticketCode: firstLine.ticket.ticketCode,
        customerName: firstLine.ticket.customer.fullName,
        customerId: firstLine.ticket.customer.id,
        serviceLines: lines
            .map((line) => WalkInServiceLine.fromTicketLineModel(line))
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
        createdAt: firstLine.ticket.createdAt,
        updatedAt: firstLine.ticket.updatedAt,
        notes: firstLine.ticket.note,
        totalPrice: firstLine.ticket.totalPrice,
        totalTips: firstLine.ticket.totalTips,
        totalDiscount: firstLine.ticket.totalDiscount,
        totalTax: firstLine.ticket.totalTax,
        totalPaid: firstLine.ticket.totalPaid,
      );
    }).toList();
  }

  Future<void> refreshWalkIns() async {
    await loadWalkIns();
  }
}
