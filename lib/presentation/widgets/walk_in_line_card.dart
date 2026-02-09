import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/utils/toast_utils.dart';
import '../../core/utils/timezone_utils.dart';
import '../../domain/entities/walk_in_ticket.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_strings.dart';
import '../../app_dependencies.dart';

const _kCardBackgroundColor = Color(0xFFF8F9FA);
  
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

  String _getRelativeTime(DateTime createdAt) {
    final minutes = TimezoneUtils.calculateWaitTimeMinutes(createdAt);
    if (minutes < 60) return '${minutes}m ago';
    final hours = (minutes / 60).floor();
    if (hours < 24) return '${hours}h ago';
    final days = (hours / 24).floor();
    return '${days}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.serviceLine.status;
    final style = _WalkInLineCardStyle.fromStatus(status);
    final canSwipe =
        status == WalkInLineStatus.waiting ||
        status == WalkInLineStatus.serving;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Container(
        decoration: BoxDecoration(
          color: _kCardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: style.cardShadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: style.cardBorderColor, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.5),
          child: canSwipe
              ? Slidable(
                  key: ValueKey(widget.serviceLine.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.3,
                    children: [_buildSlidableAction(context, status, style)],
                  ),
                  child: Container(
                    color: _kCardBackgroundColor,
                    child: _buildCardContent(status, style),
                  ),
                )
              : Container(
                  color: _kCardBackgroundColor,
                  child: _buildCardContent(status, style),
                ),
        ),
      ),
    );
  }

  CustomSlidableAction _buildSlidableAction(
    BuildContext context,
    WalkInLineStatus status,
    _WalkInLineCardStyle style,
  ) {
    return CustomSlidableAction(
      onPressed: (context) => _handleSwipeAction(context, status),
      backgroundColor: style.backgroundColor,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(style.swipeIcon, size: 28, color: Colors.white),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              status == WalkInLineStatus.waiting ? 'Start' : 'Done',
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(
    WalkInLineStatus status,
    _WalkInLineCardStyle style,
  ) {
    return RepaintBoundary(
      child: Stack(
        children: [
          Column(
            children: [
              _CardHeader(
                style: style,
                status: status,
                timeString: _getRelativeTime(widget.createdAt),
              ),
              _CardBody(
                style: style,
                customerName: widget.customerName,
                serviceName: widget.serviceLine.lineDescription,
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 7,
            child: _DecorativeDotsRow(color: style.decorativeDotColor),
          ),
          if (_isProcessing) const _LoadingOverlay(),
        ],
      ),
    );
  }

  void _handleSwipeAction(BuildContext context, WalkInLineStatus status) async {
    setState(() => _isProcessing = true);

    Slidable.of(context)?.close();

    final notifier = ref.read(walkInsNotifierProvider.notifier);
    final String? errorMessage;

    if (status == WalkInLineStatus.waiting) {
      errorMessage = await notifier.startServiceLine(widget.serviceLine.id);
    } else {
      errorMessage = await notifier.completeServiceLine(widget.serviceLine.id);
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }

    if (errorMessage != null && context.mounted) {
      ToastUtils.showError(errorMessage);
    }
  }
}

class _CardHeader extends StatelessWidget {
  final _WalkInLineCardStyle style;
  final WalkInLineStatus status;
  final String timeString;

  const _CardHeader({
    required this.style,
    required this.status,
    required this.timeString,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.headerGradientStart, style.headerGradientEnd],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          if (status == WalkInLineStatus.waiting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                    timeString,
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
    );
  }
}

class _CardBody extends StatelessWidget {
  final _WalkInLineCardStyle style;
  final String customerName;
  final String serviceName;

  const _CardBody({
    required this.style,
    required this.customerName,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.avatarSize,
            height: AppDimensions.avatarSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [style.avatarGradientStart, style.avatarGradientEnd],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: style.avatarBorderColor, width: 2),
            ),
            child: Center(
              child: Text(
                customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: style.statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.avatarFontSize,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
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
                        serviceName,
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
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
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
    );
  }
}

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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _WalkInLineCardStyle {
  final Color statusColor;
  final String statusText;
  final IconData statusIcon;
  final Color backgroundColor;
  final IconData swipeIcon;
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

  static const _waitingStyle = _WalkInLineCardStyle._(
    statusColor: Color(0xFFFF6B00),
    statusText: AppStrings.statusWaiting,
    statusIcon: Icons.schedule,
    backgroundColor: Color(0xFF00A86B),
    swipeIcon: Icons.play_arrow,
    cardShadowColor: Color(0x14000000),
    cardBorderColor: Color(0x4D999999),
    decorativeDotColor: Color(0x33FF6B00),
    headerGradientStart: Color(0x26FF6B00),
    headerGradientEnd: Color(0x14FF6B00),
    avatarGradientStart: Color(0x40FF6B00),
    avatarGradientEnd: Color(0x26FF6B00),
    avatarBorderColor: Color(0x66FF6B00),
    statusBadgeShadow: Color(0x0D000000),
    timeBadgeShadow: Color(0x4DFF6B00),
  );

  static const _servingStyle = _WalkInLineCardStyle._(
    statusColor: Color(0xFF00A86B),
    statusText: AppStrings.statusInService,
    statusIcon: Icons.spa_outlined,
    backgroundColor: Color(0xFF2196F3),
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
    statusColor: Color(0xFFE53935),
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
