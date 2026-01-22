import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app_dependencies.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class StoreSelectionPage extends ConsumerWidget {
  const StoreSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final employees = authState.verifiedEmployees;
    final isLoading = authState.loginStatus.isLoading;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // Handle login success - connect socket with new user
      if (previous?.loginStatus != next.loginStatus) {
        next.loginStatus.whenOrNull(
          data: (_) {
            // Login successful, connect socket with new user's token
            final user = next.user;
            if (user.isAuthenticated) {
              ref.read(socketNotifierProvider.notifier).connect(
                    user.token,
                    user.fullName,
                  );
            }
          },
        );
      }

      // Handle login error
      next.loginStatus.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.mainBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Fixed Header with Back Button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingL,
                  AppDimensions.spacingM,
                  AppDimensions.spacingL,
                  AppDimensions.spacingM,
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(authNotifierProvider.notifier).clearVerifiedEmployees();
                          context.pop();
                        },
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingM,
                            vertical: AppDimensions.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: AppDimensions.spacingS),
                              Text(
                                'Back',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingL),
                child: Column(
                  children: [
                    Icon(
                      Icons.store_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'Choose Your Store',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      'Select the store you want to work at today',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // Store List - Centered and Scrollable
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppDimensions.maxContentWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingL,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.white.withValues(alpha: 0.2),
                                ],
                              ),
                              border: Border.all(
                                width: 1.5,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.spacingM,
                              ),
                              itemCount: employees.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.white.withValues(alpha: 0.2),
                                indent: AppDimensions.spacingL,
                                endIndent: AppDimensions.spacingL,
                              ),
                              itemBuilder: (context, index) {
                                final employee = employees[index];
                                return _EmployeeStoreItem(
                                  name: employee.fullName,
                                  storeName: employee.storeName,
                                  avatar: employee.avatar,
                                  isLoading: isLoading,
                                  onTap: () {
                                    ref
                                        .read(authNotifierProvider.notifier)
                                        .loginWithStore(employee.storeId);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmployeeStoreItem extends StatelessWidget {
  final String name;
  final String storeName;
  final String? avatar;
  final bool isLoading;
  final VoidCallback onTap;

  const _EmployeeStoreItem({
    required this.name,
    required this.storeName,
    this.avatar,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingL,
            vertical: AppDimensions.spacingM,
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: avatar != null && avatar!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildAvatarText();
                          },
                        ),
                      )
                    : _buildAvatarText(),
              ),

              const SizedBox(width: AppDimensions.spacingM),

              // Store Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
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

              const SizedBox(width: AppDimensions.spacingS),

              // Trailing
              if (isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarText() {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}
