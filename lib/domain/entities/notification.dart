import 'package:equatable/equatable.dart';

enum NotificationType {
  newSignIn,
  appointment,
  customerUpdate,
  serviceComplete,
  general,
}

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? clientName;
  final String? avatarUrl;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.clientName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        timestamp,
        type,
        isRead,
        clientName,
        avatarUrl,
      ];
}
