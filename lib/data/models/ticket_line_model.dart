import 'package:flutter/foundation.dart';
import 'common/customer_info_model.dart';
import 'common/employee_info_model.dart';
import '../../domain/entities/walk_in_ticket.dart';

class TicketLineModel {
  final String id;
  final String itemType; // CATEGORY, PRODUCT, SERVICE
  final String ticketLineType; // REGULAR
  final String itemId;
  final String lineDescription;
  final double unitPrice;
  final int qty;
  final double tips;
  final double tax;
  final double discount;
  final double turnValue; // [MỚI] Giá trị turn (0.5, 1.0...)
  final int durationInMinutes;
  final String status; // WAITING, SERVING, DONE
  final String employeeName;
  final int displayOrder;
  final EmployeeInfoModel employee;

  // [QUAN TRỌNG] Object chứa thông tin vé cha
  final TicketInfoModel ticket;

  TicketLineModel({
    required this.id,
    required this.itemType,
    required this.ticketLineType,
    required this.itemId,
    required this.lineDescription,
    required this.unitPrice,
    required this.qty,
    required this.tips,
    required this.tax,
    required this.discount,
    required this.turnValue,
    required this.durationInMinutes,
    required this.status,
    required this.employeeName,
    required this.displayOrder,
    required this.employee,
    required this.ticket,
  });

  factory TicketLineModel.fromJson(Map<String, dynamic> json) {
    // 1. Xử lý Employee (tránh lỗi nếu API trả về null hoặc ID string)
    EmployeeInfoModel empObj;
    if (json['employee'] != null && json['employee'] is Map<String, dynamic>) {
      empObj = EmployeeInfoModel.fromJson(json['employee']);
    } else {
      // Fallback nếu không có object employee đầy đủ
      empObj = EmployeeInfoModel(
        id: json['employeeId'] ?? '',
        firstName: json['employeeName'] ?? 'Unknown',
        lastName: '',
      );
    }

    // 2. Xử lý Ticket Info (Logic thông minh: Lồng vs Phẳng)
    TicketInfoModel ticketObj;

    // Trường hợp A: Dữ liệu LỒNG (Socket đã nhào nặn hoặc cấu trúc mới)
    if (json['ticket'] != null && json['ticket'] is Map<String, dynamic>) {
      ticketObj = TicketInfoModel.fromJson(json['ticket']);
    }
    // Trường hợp B: Dữ liệu PHẲNG (API GetWalkInLines truyền thống)
    else {
      // Gom các trường phẳng thành object TicketInfoModel
      final flatTicketMap = <String, dynamic>{
        'id': json['ticketId'] ?? '',
        'ticketCode': json['ticketCode'] ?? '',
        // Lưu ý: ticketStatus là trạng thái vé, json['status'] là trạng thái line
        'status': json['ticketStatus'] ?? json['status'] ?? '',
        'note': json['ticketNote'] ?? json['note'],
        'totalPrice': json['totalPrice'],
        'totalTips': json['totalTips'],
        'totalDiscount': json['totalDiscount'],
        'totalTax': json['totalTax'],
        'totalPaid': json['totalPaid'],
        'createdAt': json['createdAt'],
        'updatedAt': json['updatedAt'],
        'customer': json['customer'],
        'payments': json['payments'] ?? [],
      };
      ticketObj = TicketInfoModel.fromJson(flatTicketMap);
    }

    return TicketLineModel(
      id: json['id'] as String? ?? '',
      itemType: json['itemType'] as String? ?? '',
      ticketLineType: json['ticketLineType'] as String? ?? 'REGULAR',
      itemId: json['itemId'] as String? ?? '',
      lineDescription: json['lineDescription'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      tips: (json['tips'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      turnValue: (json['turnValue'] as num?)?.toDouble() ?? 0.0, // [MỚI]
      durationInMinutes: (json['durationInMinutes'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      employee: empObj,
      ticket: ticketObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemType': itemType,
      'ticketLineType': ticketLineType,
      'itemId': itemId,
      'lineDescription': lineDescription,
      'unitPrice': unitPrice,
      'qty': qty,
      'tips': tips,
      'tax': tax,
      'discount': discount,
      'turnValue': turnValue,
      'durationInMinutes': durationInMinutes,
      'status': status,
      'employeeName': employeeName,
      'displayOrder': displayOrder,
      'employee': employee.toJson(),
      'ticket': ticket.toJson(),
    };
  }

  WalkInServiceLine toEntity() {
    return WalkInServiceLine(
      id: id,
      itemType: itemType,
      lineDescription: lineDescription,
      unitPrice: unitPrice,
      qty: qty,
      tips: tips,
      tax: tax,
      discount: discount,
      durationInMinutes: durationInMinutes,
      status: WalkInLineStatus.fromString(status),
      employeeName: employeeName,
      displayOrder: displayOrder,
      employeeId: employee.id,
      turnValue: turnValue, // [MỚI] Map sang Entity
    );
  }
}

class TicketInfoModel {
  final String id;
  final String ticketCode;
  final String? note;
  final double totalPrice;
  final double totalTips;
  final double totalDiscount;
  final double totalTax;
  final double totalPaid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CustomerInfoModel? customer; // Nullable
  final List<dynamic> payments;

  TicketInfoModel({
    required this.id,
    required this.ticketCode,
    this.note,
    required this.totalPrice,
    required this.totalTips,
    required this.totalDiscount,
    required this.totalTax,
    required this.totalPaid,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    required this.payments,
  });

  factory TicketInfoModel.fromJson(Map<String, dynamic> json) {
    final customerJson = json['customer'];

    // Handle null customer (for walk-in tickets without customer assigned yet)
    CustomerInfoModel? customer;
    if (customerJson != null && customerJson is Map<String, dynamic>) {
      customer = CustomerInfoModel.fromJson(customerJson);
    }

    return TicketInfoModel(
      id: json['id'] as String? ?? '',
      ticketCode: json['ticketCode'] as String? ?? '',
      note: json['note'] as String?,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      totalTips: (json['totalTips'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (json['totalDiscount'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['totalTax'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      // Parse ngày tháng an toàn
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      customer: customer,
      payments: (json['payments'] as List<dynamic>?) ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketCode': ticketCode,
      'note': note,
      'totalPrice': totalPrice,
      'totalTips': totalTips,
      'totalDiscount': totalDiscount,
      'totalTax': totalTax,
      'totalPaid': totalPaid,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'customer': customer?.toJson(),
      'payments': payments,
    };
  }
}

class TicketLinesResponse {
  final int statusCode;
  final String message;
  final List<TicketLineModel> data;
  final int totalTurn;

  TicketLinesResponse({
    required this.statusCode,
    required this.message,
    required this.data,
    required this.totalTurn,
  });

  factory TicketLinesResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>;
    final linesList = dataMap['lines'] as List<dynamic>;
    final parsedLines = <TicketLineModel>[];

    for (var i = 0; i < linesList.length; i++) {
      final item = linesList[i];
      try {
        final line = TicketLineModel.fromJson(item as Map<String, dynamic>);
        parsedLines.add(line);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('[TicketLineModel] Failed to parse line $i: $e');
          print('Data: $item');
          print('Stack trace: $stackTrace');
        }
        // Continue parsing remaining lines instead of failing completely
        continue;
      }
    }

    return TicketLinesResponse(
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      message: json['message'] as String? ?? '',
      data: parsedLines,
      totalTurn: (dataMap['totalTurn'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': {
        'lines': data.map((item) => item.toJson()).toList(),
        'totalTurn': totalTurn,
      },
    };
  }
}
