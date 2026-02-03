import 'package:equatable/equatable.dart';

class AppointmentLine extends Equatable {
  // Bạn hãy copy các trường (fields) từ Model sang đây.
  // Đảm bảo chỉ giữ lại dữ liệu, không giữ các phương thức fromJson/toJson.
  final String id;
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final int durationMinute;
  final DateTime beginTime;
  final DateTime endTime;
  final String status;
  final String? note;
  // ... thêm các trường khác tùy theo dữ liệu thực tế

  const AppointmentLine({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.durationMinute,
    required this.beginTime,
    required this.endTime,
    required this.status,
    this.note,
    // ... thêm các trường khác tùy theo dữ liệu thực tế
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    customerPhone,
    serviceName,
    durationMinute,
    beginTime,
    endTime,
    status,
    note,
  ];
}
