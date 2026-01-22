import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../presentation/theme/app_colors.dart';
import '../../presentation/theme/app_text_styles.dart';

class ToastUtils {
  ToastUtils._();

  static void showSuccess(String message) {
    _showToast(
      message,
      icon: Icons.check_circle_outline,
      color: AppColors.success,
    );
  }

  static void showError(String message) {
    _showToast(
      message,
      icon: Icons.error_outline,
      color: AppColors.error,
    );
  }

  static void showWarning(String message) {
    _showToast(
      message,
      icon: Icons.warning_amber_rounded,
      color: AppColors.warning,
      textColor: Colors.black87,
    );
  }

  static void showInfo(String message) {
    _showToast(
      message,
      icon: Icons.info_outline,
      color: AppColors.info,
    );
  }

  static void _showToast(
    String message, {
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
  }) {
    showOverlayNotification(
      (context) {
        return SlideDismissible(
          key: UniqueKey(),
          direction: DismissDirection.up,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: textColor, size: 18),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          message,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      duration: duration,
      position: NotificationPosition.top,
    );
  }
}
