import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../presentation/theme/app_colors.dart';

enum _ToastType { success, error, warning, info }

class ToastUtils {
  ToastUtils._();

  static GlobalKey<NavigatorState>? _navigatorKey;
  static OverlayEntry? _currentOverlayEntry;
  static Timer? _toastTimer;

  static void init(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  static void showSuccess(String message) {
    _showToast(message, _ToastType.success);
  }

  static void showError(String message) {
    _showToast(message, _ToastType.error);
  }

  static void showWarning(String message) {
    _showToast(message, _ToastType.warning);
  }

  static void showInfo(String message) {
    _showToast(message, _ToastType.info);
  }

  static void _removeCurrentToast() {
    _toastTimer?.cancel();
    _toastTimer = null;
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }

  static void _showToast(String message, _ToastType type) {
    final overlay = _navigatorKey?.currentState?.overlay;
    if (overlay == null) {
      debugPrint('[ToastUtils] Warning: Navigator overlay not available');
      return;
    }

    // Remove existing toast
    _removeCurrentToast();

    final color = _getColorForType(type);
    final icon = _getIconForType(type);
    final title = _getTitleForType(type);

    _currentOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => _removeCurrentToast(),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(minHeight: 90, maxHeight: 90),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.95),
                            color.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon with circular background
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          // Title + Message column
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  message,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_currentOverlayEntry!);

    // Auto-dismiss after 3 seconds
    _toastTimer = Timer(const Duration(seconds: 3), _removeCurrentToast);
  }

  static String _getTitleForType(_ToastType type) {
    switch (type) {
      case _ToastType.success:
        return 'Success';
      case _ToastType.error:
        return 'Error';
      case _ToastType.warning:
        return 'Warning';
      case _ToastType.info:
        return 'Info';
    }
  }

  static IconData _getIconForType(_ToastType type) {
    switch (type) {
      case _ToastType.success:
        return Icons.check_circle;
      case _ToastType.error:
        return Icons.error;
      case _ToastType.warning:
        return Icons.warning_amber_rounded;
      case _ToastType.info:
        return Icons.info;
    }
  }

  static Color _getColorForType(_ToastType type) {
    switch (type) {
      case _ToastType.success:
        return AppColors.success;
      case _ToastType.error:
        return AppColors.error;
      case _ToastType.warning:
        return AppColors.warning;
      case _ToastType.info:
        return AppColors.info;
    }
  }
}
