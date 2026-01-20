import 'package:equatable/equatable.dart';
import '../../data/models/ticket_line_model.dart';

enum WalkInLineStatus {
  waiting,
  serving,
  done,
  canceled;

  static WalkInLineStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'WAITING':
        return waiting;
      case 'SERVING':
        return serving;
      case 'DONE':
        return done;
      case 'CANCELED':
        return canceled;
      default:
        return waiting;
    }
  }
}

class WalkInTicket extends Equatable {
  final String ticketId;
  final String ticketCode;
  final String customerName;
  final String customerId;
  final List<WalkInServiceLine> serviceLines;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final double totalPrice;
  final double totalTips;
  final double totalDiscount;
  final double totalTax;
  final double totalPaid;

  const WalkInTicket({
    required this.ticketId,
    required this.ticketCode,
    required this.customerName,
    required this.customerId,
    required this.serviceLines,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    required this.totalPrice,
    required this.totalTips,
    required this.totalDiscount,
    required this.totalTax,
    required this.totalPaid,
  });

  WalkInLineStatus get overallStatus {
    // If any line is serving, ticket is serving
    if (serviceLines.any((line) => line.status == WalkInLineStatus.serving)) {
      return WalkInLineStatus.serving;
    }
    // If all are waiting, ticket is waiting
    if (serviceLines.every((line) => line.status == WalkInLineStatus.waiting)) {
      return WalkInLineStatus.waiting;
    }
    // If all are canceled, ticket is canceled
    if (serviceLines.every((line) => line.status == WalkInLineStatus.canceled)) {
      return WalkInLineStatus.canceled;
    }
    // Otherwise done
    return WalkInLineStatus.done;
  }

  String get primaryEmployeeName =>
      serviceLines.isNotEmpty ? serviceLines.first.employeeName : 'Unassigned';

  @override
  List<Object?> get props => [
        ticketId,
        ticketCode,
        customerName,
        customerId,
        serviceLines,
        createdAt,
        updatedAt,
        notes,
        totalPrice,
        totalTips,
        totalDiscount,
        totalTax,
        totalPaid,
      ];
}

class WalkInServiceLine extends Equatable {
  final String id;
  final String lineDescription;
  final double unitPrice;
  final int qty;
  final double tips;
  final double tax;
  final double discount;
  final int durationInMinutes;
  final WalkInLineStatus status;
  final String employeeName;
  final int displayOrder;
  final String? employeeId;

  const WalkInServiceLine({
    required this.id,
    required this.lineDescription,
    required this.unitPrice,
    required this.qty,
    required this.tips,
    required this.tax,
    required this.discount,
    required this.durationInMinutes,
    required this.status,
    required this.employeeName,
    required this.displayOrder,
    this.employeeId,
  });

  factory WalkInServiceLine.fromTicketLineModel(TicketLineModel model) {
    return WalkInServiceLine(
      id: model.id,
      lineDescription: model.lineDescription,
      unitPrice: model.unitPrice,
      qty: model.qty,
      tips: model.tips,
      tax: model.tax,
      discount: model.discount,
      durationInMinutes: model.durationInMinutes,
      status: WalkInLineStatus.fromString(model.status),
      employeeName: model.employeeName,
      displayOrder: model.displayOrder,
      employeeId: model.employee.id,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lineDescription,
        unitPrice,
        qty,
        tips,
        tax,
        discount,
        durationInMinutes,
        status,
        employeeName,
        displayOrder,
        employeeId,
      ];
}
