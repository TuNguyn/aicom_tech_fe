class TicketLineModel {
  final String id;
  final String itemType; // CATEGORY, PRODUCT
  final String ticketLineType; // REGULAR
  final String itemId;
  final String lineDescription;
  final double unitPrice;
  final int qty;
  final double tips;
  final double tax;
  final double discount;
  final double turnValue;
  final int durationInMinutes;
  final String status; // WAITING, SERVING, DONE
  final String employeeName;
  final int displayOrder;
  final EmployeeInfoModel employee;
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
    return TicketLineModel(
      id: json['id'] as String,
      itemType: json['itemType'] as String,
      ticketLineType: json['ticketLineType'] as String,
      itemId: json['itemId'] as String,
      lineDescription: json['lineDescription'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      qty: json['qty'] as int,
      tips: (json['tips'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      turnValue: (json['turnValue'] as num).toDouble(),
      durationInMinutes: json['durationInMinutes'] as int,
      status: json['status'] as String,
      employeeName: json['employeeName'] as String,
      displayOrder: json['displayOrder'] as int,
      employee: EmployeeInfoModel.fromJson(json['employee'] as Map<String, dynamic>),
      ticket: TicketInfoModel.fromJson(json['ticket'] as Map<String, dynamic>),
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
  final CustomerInfoModel customer;
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
    required this.customer,
    required this.payments,
  });

  factory TicketInfoModel.fromJson(Map<String, dynamic> json) {
    return TicketInfoModel(
      id: json['id'] as String,
      ticketCode: json['ticketCode'] as String,
      note: json['note'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalTips: (json['totalTips'] as num).toDouble(),
      totalDiscount: (json['totalDiscount'] as num).toDouble(),
      totalTax: (json['totalTax'] as num).toDouble(),
      totalPaid: (json['totalPaid'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      customer: CustomerInfoModel.fromJson(json['customer'] as Map<String, dynamic>),
      payments: json['payments'] as List<dynamic>,
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
      'customer': customer.toJson(),
      'payments': payments,
    };
  }
}

class CustomerInfoModel {
  final String id;
  final String firstName;
  final String lastName;

  CustomerInfoModel({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';

  factory CustomerInfoModel.fromJson(Map<String, dynamic> json) {
    return CustomerInfoModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class EmployeeInfoModel {
  final String id;
  final String firstName;
  final String lastName;

  EmployeeInfoModel({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';

  factory EmployeeInfoModel.fromJson(Map<String, dynamic> json) {
    return EmployeeInfoModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class TicketLinesResponse {
  final int statusCode;
  final String message;
  final List<TicketLineModel> data;

  TicketLinesResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory TicketLinesResponse.fromJson(Map<String, dynamic> json) {
    return TicketLinesResponse(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => TicketLineModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
