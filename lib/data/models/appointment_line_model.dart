class AppointmentLineModel {
  final String id;
  final DateTime beginTime;
  final int durationMinute;
  final String type;
  final ServiceInfoModel service;
  final AppointmentInfoModel appointment;
  final EmployeeInfoModel employee;

  AppointmentLineModel({
    required this.id,
    required this.beginTime,
    required this.durationMinute,
    required this.type,
    required this.service,
    required this.appointment,
    required this.employee,
  });

  factory AppointmentLineModel.fromJson(Map<String, dynamic> json) {
    return AppointmentLineModel(
      id: json['id'] as String,
      beginTime: DateTime.parse(json['beginTime'] as String),
      durationMinute: json['durationMinute'] as int,
      type: json['type'] as String,
      service: ServiceInfoModel.fromJson(json['service'] as Map<String, dynamic>),
      appointment: AppointmentInfoModel.fromJson(json['appointment'] as Map<String, dynamic>),
      employee: EmployeeInfoModel.fromJson(json['employee'] as Map<String, dynamic>),
    );
  }

  DateTime get endTime => beginTime.add(Duration(minutes: durationMinute));
}

class ServiceInfoModel {
  final String id;
  final String name;

  ServiceInfoModel({
    required this.id,
    required this.name,
  });

  factory ServiceInfoModel.fromJson(Map<String, dynamic> json) {
    return ServiceInfoModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class AppointmentInfoModel {
  final String id;
  final DateTime appointmentTime;
  final String status;
  final String? note;
  final CustomerInfoModel customer;

  AppointmentInfoModel({
    required this.id,
    required this.appointmentTime,
    required this.status,
    this.note,
    required this.customer,
  });

  factory AppointmentInfoModel.fromJson(Map<String, dynamic> json) {
    return AppointmentInfoModel(
      id: json['id'] as String,
      appointmentTime: DateTime.parse(json['appointmentTime'] as String),
      status: json['status'] as String,
      note: json['note'] as String?,
      customer: CustomerInfoModel.fromJson(json['customer'] as Map<String, dynamic>),
    );
  }
}

class CustomerInfoModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;

  CustomerInfoModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  String get fullName => '$firstName $lastName';

  factory CustomerInfoModel.fromJson(Map<String, dynamic> json) {
    return CustomerInfoModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
    );
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
}

class AppointmentLinesResponse {
  final List<AppointmentLineModel> data;
  final PaginationMeta meta;
  final PaginationLinks links;

  AppointmentLinesResponse({
    required this.data,
    required this.meta,
    required this.links,
  });

  factory AppointmentLinesResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>;

    return AppointmentLinesResponse(
      data: (dataMap['data'] as List<dynamic>)
          .map((item) => AppointmentLineModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(dataMap['meta'] as Map<String, dynamic>),
      links: PaginationLinks.fromJson(dataMap['links'] as Map<String, dynamic>),
    );
  }
}

class PaginationMeta {
  final int itemsPerPage;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final List<List<String>> sortBy;

  PaginationMeta({
    required this.itemsPerPage,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.sortBy,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      itemsPerPage: json['itemsPerPage'] as int,
      totalItems: json['totalItems'] as int,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      sortBy: (json['sortBy'] as List<dynamic>)
          .map((item) => (item as List<dynamic>).cast<String>())
          .toList(),
    );
  }
}

class PaginationLinks {
  final String current;

  PaginationLinks({required this.current});

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      current: json['current'] as String,
    );
  }
}
