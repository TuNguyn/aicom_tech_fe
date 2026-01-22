// ignore_for_file: avoid_print

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ticket_line_model.dart';
import '../../domain/entities/walk_in_ticket.dart';
import '../../domain/usecases/walk_ins/get_walk_in_lines.dart';
import '../../domain/usecases/walk_ins/start_walk_in_line.dart';
import '../../domain/usecases/walk_ins/complete_walk_in_line.dart';

/// Display model for individual service lines with customer info
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

  const WalkInsState({
    this.walkInTickets = const [],
    this.loadingStatus = const AsyncValue.data(null),
  });

  List<WalkInTicket> get sortedTickets {
    final tickets = List<WalkInTicket>.from(walkInTickets);
    tickets.sort((a, b) => _compareByStatus(
          a.overallStatus,
          b.overallStatus,
          a.createdAt,
          b.createdAt,
        ));
    return tickets;
  }

  /// Returns count of tickets that are not fully done (pending/in-progress)
  int get pendingTicketsCount {
    return walkInTickets.where((ticket) {
      return ticket.overallStatus != WalkInLineStatus.done &&
          ticket.overallStatus != WalkInLineStatus.canceled;
    }).length;
  }

  /// Returns flattened and sorted service lines from all tickets
  List<ServiceLineDisplay> get sortedServiceLines {
    // Flatten service lines from tickets
    final lines = <ServiceLineDisplay>[];
    for (final ticket in walkInTickets) {
      for (final serviceLine in ticket.serviceLines) {
        lines.add(
          ServiceLineDisplay(
            customerName: ticket.customerName,
            serviceLine: serviceLine,
            createdAt: ticket.createdAt,
          ),
        );
      }
    }

    // Sort lines: waiting first, then serving, then done, then by creation time
    lines.sort((a, b) => _compareByStatus(
          a.serviceLine.status,
          b.serviceLine.status,
          a.createdAt,
          b.createdAt,
        ));

    return lines;
  }

  /// Compare two items by status priority and creation time
  static int _compareByStatus(
    WalkInLineStatus statusA,
    WalkInLineStatus statusB,
    DateTime createdAtA,
    DateTime createdAtB,
  ) {
    // Waiting status first
    if (statusA == WalkInLineStatus.waiting &&
        statusB != WalkInLineStatus.waiting) {
      return -1;
    }
    if (statusA != WalkInLineStatus.waiting &&
        statusB == WalkInLineStatus.waiting) {
      return 1;
    }

    // Serving status second
    if (statusA == WalkInLineStatus.serving &&
        statusB != WalkInLineStatus.serving &&
        statusB != WalkInLineStatus.waiting) {
      return -1;
    }
    if (statusA != WalkInLineStatus.serving &&
        statusA != WalkInLineStatus.waiting &&
        statusB == WalkInLineStatus.serving) {
      return 1;
    }

    // Done status third
    if (statusA == WalkInLineStatus.done &&
        statusB == WalkInLineStatus.canceled) {
      return -1;
    }
    if (statusA == WalkInLineStatus.canceled &&
        statusB == WalkInLineStatus.done) {
      return 1;
    }

    // Then by creation time (newest first)
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
  List<Object?> get props => [walkInTickets, loadingStatus];
}

class WalkInsNotifier extends StateNotifier<WalkInsState> {
  final GetWalkInLines _getWalkInLines;
  final StartWalkInLine _startWalkInLine;
  final CompleteWalkInLine _completeWalkInLine;

  bool _isDataLoaded = false;

  WalkInsNotifier(
    this._getWalkInLines,
    this._startWalkInLine,
    this._completeWalkInLine,
  ) : super(const WalkInsState());

  Future<void> loadWalkIns({List<String>? statuses}) async {
    // Skip if already loaded or currently loading
    if (_isDataLoaded || state.loadingStatus.isLoading) {
      return;
    }

    state = state.copyWith(loadingStatus: const AsyncValue.loading());

    final result = await _getWalkInLines(
      statuses: statuses ?? ['WAITING', 'SERVING', 'DONE', 'CANCELED'],
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

        _isDataLoaded = true;
      },
    );
  }

  List<WalkInTicket> _groupTicketLines(List<TicketLineModel> lines) {
    // Debug: Show line statuses (important for debugging start -> done issue)
    print('[Lines] Received ${lines.length} lines:');
    for (var line in lines) {
      print('  ${line.id.substring(0, 8)}: ${line.status} - ${line.lineDescription}');
    }

    // Group by ticket ID
    final ticketsMap = <String, List<TicketLineModel>>{};
    for (final line in lines) {
      ticketsMap.putIfAbsent(line.ticket.id, () => []).add(line);
    }

    // Get today's date range
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Transform to WalkInTicket entities
    final allTickets = ticketsMap.entries.map((entry) {
      final lines = entry.value;
      final firstLine = lines.first;

      final customer = firstLine.ticket.customer;
      final customerName = customer?.fullName ?? 'Visitor';
      final customerId = customer?.id ?? '';

      return WalkInTicket(
        ticketId: firstLine.ticket.id,
        ticketCode: firstLine.ticket.ticketCode,
        customerName: customerName,
        customerId: customerId,
        serviceLines: lines
            .map((line) => line.toEntity())
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

    // Filter: only include tickets created today
    final todayTickets = allTickets.where((ticket) {
      return ticket.createdAt.isAfter(today.subtract(const Duration(seconds: 1))) &&
          ticket.createdAt.isBefore(tomorrow);
    }).toList();

    return todayTickets;
  }

  Future<void> refreshWalkIns() async {
    _isDataLoaded = false;
    await loadWalkIns();
  }

  /// Start a walk-in service line. Returns true if successful.
  Future<bool> startServiceLine(String lineId) async {
    print('[Action] START line: ${lineId.substring(0, 8)}');

    final result = await _startWalkInLine(lineId);

    return result.fold(
      (failure) {
        print('[Action] START failed: ${failure.message}');
        return false;
      },
      (_) {
        print('[Action] START success, refreshing...');
        refreshWalkIns();
        return true;
      },
    );
  }

  /// Complete a walk-in service line. Returns true if successful.
  Future<bool> completeServiceLine(String lineId) async {
    print('[Action] COMPLETE line: ${lineId.substring(0, 8)}');

    final result = await _completeWalkInLine(lineId);

    return result.fold(
      (failure) {
        print('[Action] COMPLETE failed: ${failure.message}');
        return false;
      },
      (_) {
        print('[Action] COMPLETE success, refreshing...');
        refreshWalkIns();
        return true;
      },
    );
  }
}
