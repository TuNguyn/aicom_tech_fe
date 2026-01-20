import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../../app_dependencies.dart';
import '../../routes/app_routes.dart';

class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const LogoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge - 1.5),
              child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with gradient background
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.error.withValues(alpha: 0.2),
                            AppColors.error.withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        size: 32,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),

                    // Title
                    Text(
                      'Logout',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingS),

                    // Description
                    Text(
                      'Are you sure you want to logout from your account?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingL),

                    // Action buttons
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: _GlassButton(
                            onPressed: () => Navigator.of(context).pop(),
                            label: 'Cancel',
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingS),

                        // Logout button
                        Expanded(
                          child: _GlassButton(
                            onPressed: authState.logoutStatus.isLoading
                                ? null
                                : () async {
                                    await ref.read(authNotifierProvider.notifier).logout();

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      // Navigate to login page using go_router
                                      context.go(AppRoutes.login);
                                    }
                                  },
                            label: authState.logoutStatus.isLoading
                                ? 'Processing...'
                                : 'Logout',
                            isPrimary: true,
                            isLoading: authState.logoutStatus.isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isPrimary;
  final bool isLoading;

  const _GlassButton({
    required this.onPressed,
    required this.label,
    required this.isPrimary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary
        ? AppColors.error.withValues(alpha: 0.15)
        : Colors.grey.shade100;

    final borderColor = isPrimary
        ? AppColors.error.withValues(alpha: 0.4)
        : Colors.grey.shade300;

    final textColor = isPrimary ? AppColors.error : Colors.grey.shade700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
