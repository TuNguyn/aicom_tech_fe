import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/notification.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Mock notifications data
  final List<NotificationEntity> _notifications = [
    NotificationEntity(
      id: '1',
      title: 'New Signed-In',
      message: 'Client: Nhan',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.newSignIn,
      clientName: 'Nhan',
      isRead: false,
    ),
    NotificationEntity(
      id: '2',
      title: 'Appointment Reminder',
      message: 'Client: Sarah Johnson at 2:00 PM',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.appointment,
      clientName: 'Sarah Johnson',
      isRead: false,
    ),
    NotificationEntity(
      id: '3',
      title: 'Service Completed',
      message: 'Client: Maria Garcia finished manicure service',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.serviceComplete,
      clientName: 'Maria Garcia',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notification',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              _showDeleteAllDialog();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: _notifications.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationItem(notification);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationEntity notification) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _markAsRead(notification);
          },
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _buildAvatar(notification),
                const SizedBox(width: AppDimensions.spacingM),

                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (notification.clientName != null)
                        Text(
                          '• ${notification.message}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey[800],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '• ${_formatTime(notification.timestamp)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread indicator
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(NotificationEntity notification) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: notification.avatarUrl != null
          ? ClipOval(
              child: Image.network(
                notification.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(notification);
                },
              ),
            )
          : _buildDefaultAvatar(notification),
    );
  }

  Widget _buildDefaultAvatar(NotificationEntity notification) {
    return Center(
      child: Text(
        notification.clientName?.substring(0, 1).toUpperCase() ?? 'N',
        style: AppTextStyles.displayMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'No Notifications',
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'You don\'t have any notifications yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('h:mm a').format(timestamp)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  void _markAsRead(NotificationEntity notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = NotificationEntity(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          timestamp: notification.timestamp,
          type: notification.type,
          clientName: notification.clientName,
          avatarUrl: notification.avatarUrl,
          isRead: true,
        );
      }
    });
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete All Notifications', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to delete all notifications?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
