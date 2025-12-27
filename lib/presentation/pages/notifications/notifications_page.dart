import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Mock notifications data - simplified format
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Appointment Reminder',
      'message': 'Sarah Johnson at 10:00 AM',
      'time': '5m ago',
      'icon': Icons.event_available,
      'color': AppColors.primary,
    },
    {
      'id': '2',
      'title': 'New Walk-in Customer',
      'message': 'Customer waiting at front desk',
      'time': '12m ago',
      'icon': Icons.person_add_outlined,
      'color': AppColors.accent,
    },
    {
      'id': '3',
      'title': 'Payment Received',
      'message': 'Ticket #00003 - \$35.00',
      'time': '1h ago',
      'icon': Icons.payment,
      'color': AppColors.success,
    },
    {
      'id': '4',
      'title': 'Appointment Cancelled',
      'message': 'Maria Garcia cancelled 2:30 PM slot',
      'time': '2h ago',
      'icon': Icons.event_busy,
      'color': AppColors.error,
    },
    {
      'id': '5',
      'title': 'New Review',
      'message': 'Jennifer Smith left a 5-star review',
      'time': '3h ago',
      'icon': Icons.star,
      'color': Colors.amber,
    },
    {
      'id': '6',
      'title': 'Stock Alert',
      'message': 'Gel polish running low - reorder needed',
      'time': '4h ago',
      'icon': Icons.inventory_2_outlined,
      'color': AppColors.warning,
    },
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
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationItem(notification, index);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    return Dismissible(
      key: ValueKey(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((n) => n['id'] == notification['id']);
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (notification['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: notification['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'] as String,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                notification['time'] as String,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
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
