import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/utils/toast_utils.dart';
import '../../domain/entities/walk_in_ticket.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_strings.dart';
import '../../app_dependencies.dart';

// Cache for status-based styling to avoid repeated calculations
class _WalkInLineCardStyle {
  final Color statusColor;
  final String statusText;
  final IconData statusIcon;
  final Color backgroundColor;
  final IconData swipeIcon;

  // Pre-calculated color variations with alpha
  final Color cardShadowColor;
  final Color cardBorderColor;
  final Color decorativeDotColor;
  final Color headerGradientStart;
  final Color headerGradientEnd;
  final Color avatarGradientStart;
  final Color avatarGradientEnd;
  final Color avatarBorderColor;
  final Color statusBadgeShadow;
  final Color timeBadgeShadow;

  const _WalkInLineCardStyle._({
    required this.statusColor,
    required this.statusText,
    required this.statusIcon,
    required this.backgroundColor,
    required this.swipeIcon,
    required this.cardShadowColor,
    required this.cardBorderColor,
    required this.decorativeDotColor,
    required this.headerGradientStart,
    required this.headerGradientEnd,
    required this.avatarGradientStart,
    required this.avatarGradientEnd,
    required this.avatarBorderColor,
    required this.statusBadgeShadow,
    required this.timeBadgeShadow,
  });

  // Pre-defined styles for each status (const for better performance)
  static const _waitingStyle = _WalkInLineCardStyle._(
    statusColor: Color(0xFFFF6B00), // Vibrant orange
    statusText: AppStrings.statusWaiting,
    statusIcon: Icons.schedule,
    backgroundColor: Color(0xFF00A86B), // Green for start
    swipeIcon: Icons.play_arrow,
    cardShadowColor: Color(0x14000000),        // 0.08 alpha
    cardBorderColor: Color(0x4D999999),        // 0.3 alpha
    decorativeDotColor: Color(0x33FF6B00),     // 0.2 alpha
    headerGradientStart: Color(0x26FF6B00),    // 0.15 alpha
    headerGradientEnd: Color(0x14FF6B00),      // 0.08 alpha
    avatarGradientStart: Color(0x40FF6B00),    // 0.25 alpha
    avatarGradientEnd: Color(0x26FF6B00),      // 0.15 alpha
    avatarBorderColor: Color(0x66FF6B00),      // 0.4 alpha
    statusBadgeShadow: Color(0x0D000000),      // 0.05 alpha
    timeBadgeShadow: Color(0x4DFF6B00),        // 0.3 alpha
  );

  static const _servingStyle = _WalkInLineCardStyle._(
    statusColor: Color(0xFF00A86B), // Vibrant jade green
    statusText: AppStrings.statusInService,
    statusIcon: Icons.spa_outlined,
    backgroundColor: Color(0xFF2196F3), // Blue for complete
    swipeIcon: Icons.check_circle,
    cardShadowColor: Color(0x14000000),
    cardBorderColor: Color(0x4D999999),
    decorativeDotColor: Color(0x3300A86B),
    headerGradientStart: Color(0x2600A86B),
    headerGradientEnd: Color(0x1400A86B),
    avatarGradientStart: Color(0x4000A86B),
    avatarGradientEnd: Color(0x2600A86B),
    avatarBorderColor: Color(0x6600A86B),
    statusBadgeShadow: Color(0x0D000000),
    timeBadgeShadow: Color(0x4D00A86B),
  );

  static const _doneStyle = _WalkInLineCardStyle._(
    statusColor: Colors.grey,
    statusText: AppStrings.statusDone,
    statusIcon: Icons.check_circle_outline,
    backgroundColor: Colors.grey,
    swipeIcon: Icons.check_circle,
    cardShadowColor: Color(0x14000000),
    cardBorderColor: Color(0x4D999999),
    decorativeDotColor: Color(0x33999999),
    headerGradientStart: Color(0x26999999),
    headerGradientEnd: Color(0x14999999),
    avatarGradientStart: Color(0x40999999),
    avatarGradientEnd: Color(0x26999999),
    avatarBorderColor: Color(0x66999999),
    statusBadgeShadow: Color(0x0D000000),
    timeBadgeShadow: Color(0x4D999999),
  );

  static const _canceledStyle = _WalkInLineCardStyle._(
    statusColor: Color(0xFFE53935), // Red for canceled
    statusText: 'Cancelled',
    statusIcon: Icons.cancel,
    backgroundColor: Color(0xFFE53935),
    swipeIcon: Icons.cancel,
    cardShadowColor: Color(0x14000000),
    cardBorderColor: Color(0x4D999999),
    decorativeDotColor: Color(0x33E53935),
    headerGradientStart: Color(0x26E53935),
    headerGradientEnd: Color(0x14E53935),
    avatarGradientStart: Color(0x40E53935),
    avatarGradientEnd: Color(0x26E53935),
    avatarBorderColor: Color(0x66E53935),
    statusBadgeShadow: Color(0x0D000000),
    timeBadgeShadow: Color(0x4DE53935),
  );

  static _WalkInLineCardStyle fromStatus(WalkInLineStatus status) {
    switch (status) {
      case WalkInLineStatus.waiting:
        return _waitingStyle;
      case WalkInLineStatus.serving:
        return _servingStyle;
      case WalkInLineStatus.done:
        return _doneStyle;
      case WalkInLineStatus.canceled:
        return _canceledStyle;
    }
  }
}

/// Card widget to display a single service line
class WalkInLineCard extends ConsumerStatefulWidget {
  final String customerName;
  final WalkInServiceLine serviceLine;
  final DateTime createdAt;

  const WalkInLineCard({
    super.key,
    required this.customerName,
    required this.serviceLine,
    required this.createdAt,
  });

  @override
  ConsumerState<WalkInLineCard> createState() => _WalkInLineCardState();
}

class _WalkInLineCardState extends ConsumerState<WalkInLineCard> {
  bool _isProcessing = false;
  String? _cachedRelativeTime;
  DateTime? _lastTimeUpdate;

  // Cache relative time calculation with 1-minute granularity
  String _getRelativeTime(DateTime createdAt) {
    final now = DateTime.now();

    // Only recalculate if minute has changed
    if (_cachedRelativeTime == null ||
        _lastTimeUpdate == null ||
        now.difference(_lastTimeUpdate!).inMinutes >= 1) {
      final diff = now.difference(createdAt);
      if (diff.inMinutes < 60) {
        _cachedRelativeTime = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        _cachedRelativeTime = '${diff.inHours}h ago';
      } else {
        _cachedRelativeTime = '${diff.inDays}d ago';
      }
      _lastTimeUpdate = now;
    }

    return _cachedRelativeTime!;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.serviceLine.status;
    final style = _WalkInLineCardStyle.fromStatus(status);

    // Enable swipe for WAITING and SERVING status only (not for DONE or CANCELED)
    final canSwipe = status == WalkInLineStatus.waiting ||
                     status == WalkInLineStatus.serving;

    final cardContent = _buildCardContent(context, status, style);

    if (!canSwipe) {
      return cardContent;
    }

    return Slidable(
      key: ValueKey(widget.serviceLine.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (context) => _handleSwipeAction(context, status),
            backgroundColor: style.backgroundColor,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  style.swipeIcon,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  status == WalkInLineStatus.waiting ? 'Start' : 'Done',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: cardContent,
    );
  }

  Widget _buildCardContent(BuildContext context, WalkInLineStatus status, _WalkInLineCardStyle style) {

    return RepaintBoundary(
      child: Stack(
        children: [
          Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: style.cardShadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: style.cardBorderColor,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Decorative dots pattern (top right)
              Positioned(
                top: 10,
                right: 7,
                child: _DecorativeDotsRow(color: style.decorativeDotColor),
              ),

              Column(
                children: [
                  // Compact header with status and time
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          style.headerGradientStart,
                          style.headerGradientEnd,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: style.statusColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: style.statusBadgeShadow,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                style.statusIcon,
                                size: AppDimensions.statusIconSize,
                                color: style.statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                style.statusText,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: style.statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Created time badge - only show for WAITING status
                        if (status == WalkInLineStatus.waiting)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: style.statusColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: style.timeBadgeShadow,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.white,
                                  size: AppDimensions.statusBadgeIconSize,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getRelativeTime(widget.createdAt),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content - Avatar and service info
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Container(
                          width: AppDimensions.avatarSize,
                          height: AppDimensions.avatarSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                style.avatarGradientStart,
                                style.avatarGradientEnd,
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: style.avatarBorderColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.customerName.isNotEmpty ? widget.customerName[0].toUpperCase() : '?',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: style.statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: AppDimensions.avatarFontSize,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Name and service
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Customer name
                              Text(
                                widget.customerName,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              // Service line
                              Row(
                                children: [
                                  Container(
                                    width: AppDimensions.decorativeDotSize,
                                    height: AppDimensions.decorativeDotSize,
                                    decoration: BoxDecoration(
                                      color: style.statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.serviceLine.lineDescription,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.grey[800],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
          // Subtle loading overlay when processing
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Processing',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleSwipeAction(
    BuildContext context,
    WalkInLineStatus status,
  ) async {
    // Show processing state
    setState(() {
      _isProcessing = true;
    });

    // Close the slidable
    Slidable.of(context)?.close();

    final notifier = ref.read(walkInsNotifierProvider.notifier);

    // Call appropriate API based on status
    final String? errorMessage;

    if (status == WalkInLineStatus.waiting) {
      // Start the service
      errorMessage = await notifier.startServiceLine(widget.serviceLine.id);
    } else {
      // Complete the service (SERVING status)
      errorMessage = await notifier.completeServiceLine(widget.serviceLine.id);
    }

    // Clear processing state
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }

    if (errorMessage != null && context.mounted) {
      // Show error message from the API
      ToastUtils.showError(errorMessage);
    }
    // Data is automatically refreshed (on both success and error) by the provider
  }
}

// Widget for decorative dots row with dynamic color
class _DecorativeDotsRow extends StatelessWidget {
  final Color color;

  const _DecorativeDotsRow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(color),
        const SizedBox(width: 3),
        _dot(color),
        const SizedBox(width: 3),
        _dot(color),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: AppDimensions.decorativeDotSize,
      height: AppDimensions.decorativeDotSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
