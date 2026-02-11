import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_dependencies.dart';
import '../providers/connectivity_provider.dart';
import '../theme/app_colors.dart';

class ConnectivityBanner extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  ConsumerState<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner> {
  bool _showBanner = false;
  bool _isOnline = true;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ConnectivityState>(connectivityNotifierProvider, (prev, next) {
      _hideTimer?.cancel();

      if (next.isOffline) {
        setState(() {
          _showBanner = true;
          _isOnline = false;
        });
      } else if (next.justCameBackOnline) {
        setState(() {
          _showBanner = true;
          _isOnline = true;
        });
        _hideTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _showBanner = false);
          }
        });
      }
    });

    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        widget.child,
        // Pill banner positioned just below status bar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          top: _showBanner ? topPadding + 4 : -(topPadding + 40),
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _isOnline ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isOnline ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isOnline ? Icons.wifi : Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isOnline ? 'Back online' : 'You are offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
