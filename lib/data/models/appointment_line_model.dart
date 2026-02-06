import '../../domain/entities/appointment_line.dart';
// [THÊM] Import file TimezoneUtils
import '../../core/utils/timezone_utils.dart';
import 'common/customer_info_model.dart';
import 'common/employee_info_model.dart';
import 'common/pagination_models.dart';

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
      id: json['id'] as String? ?? '',

      // [SỬA] Dùng TimezoneUtils để parse và convert sang Local Time
      // Hàm này sẽ tự xử lý null check và fallback bên trong nếu cần thiết
      beginTime: TimezoneUtils.parseJsonDateTime(json['beginTime']),

      durationMinute: (json['durationMinute'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      service: ServiceInfoModel.fromJson(
        json['service'] as Map<String, dynamic>,
      ),
      appointment: AppointmentInfoModel.fromJson(
        json['appointment'] as Map<String, dynamic>,
      ),
      employee: EmployeeInfoModel.fromJson(
        json['employee'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Khi gửi lên server, nên convert ngược lại UTC (nếu TimezoneUtils có hỗ trợ)
      // Hoặc giữ nguyên toIso8601String() nếu server tự hiểu
      'beginTime': beginTime.toIso8601String(),
      'durationMinute': durationMinute,
      'type': type,
      'service': service.toJson(),
      'appointment': appointment.toJson(),
      'employee': employee.toJson(),
    };
  }

  DateTime get endTime => beginTime.add(Duration(minutes: durationMinute));

  AppointmentLine toEntity() {
    return AppointmentLine(
      id: id,
      appointmentId: appointment.id,
      customerName: appointment.customer.fullName,
      customerPhone: appointment.customer.phone,
      serviceName: service.name,
      durationMinute: durationMinute,
      beginTime: beginTime, // Đã là Local Time
      endTime: endTime, // Đã là Local Time
      status: appointment.status,
    );
  }
}

class ServiceInfoModel {
  final String id;
  final String name;

  ServiceInfoModel({required this.id, required this.name});

  factory ServiceInfoModel.fromJson(Map<String, dynamic> json) {
    return ServiceInfoModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
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
      id: json['id'] as String? ?? '',

      // [SỬA] Áp dụng tương tự cho appointmentTime
      appointmentTime: TimezoneUtils.parseJsonDateTime(json['appointmentTime']),

      status: json['status'] as String? ?? '',
      note: json['note'] as String?,
      customer: CustomerInfoModel.fromJson(
        json['customer'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentTime': appointmentTime.toIso8601String(),
      'status': status,
      'note': note,
      'customer': customer.toJson(),
    };
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
    // Kiểm tra null safety cho dataMap để tránh crash nếu API trả lỗi
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};
    final listData = dataMap['data'] as List<dynamic>? ?? [];

    return AppointmentLinesResponse(
      data: listData
          .map(
            (item) =>
                AppointmentLineModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      meta: dataMap['meta'] != null
          ? PaginationMeta.fromJson(dataMap['meta'] as Map<String, dynamic>)
          : PaginationMeta.empty(), // Cần đảm bảo PaginationMeta có hàm empty() hoặc xử lý null
      links: dataMap['links'] != null
          ? PaginationLinks.fromJson(dataMap['links'] as Map<String, dynamic>)
          : PaginationLinks.empty(), // Tương tự
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'data': data.map((item) => item.toJson()).toList(),
        'meta': meta.toJson(),
        'links': links.toJson(),
      },
    };
  }
}
