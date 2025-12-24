import 'package:aicom_tech_fe/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nail Tech App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.mainBackgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user.fullName}!',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXl),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimensions.spacingM,
                    mainAxisSpacing: AppDimensions.spacingM,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.calendar_today,
                        title: 'Appointments',
                        subtitle: 'View your schedule',
                        color: AppColors.primary,
                        onTap: () {
                          // TODO: Navigate to appointments
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.build,
                        title: 'Services',
                        subtitle: 'Track progress',
                        color: AppColors.secondary,
                        onTap: () {
                          // TODO: Navigate to services
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.people,
                        title: 'Customers',
                        subtitle: 'View customer info',
                        color: AppColors.accent,
                        onTap: () {
                          // TODO: Navigate to customers
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.person,
                        title: 'Profile',
                        subtitle: 'Manage your profile',
                        color: AppColors.info,
                        onTap: () {
                          // TODO: Navigate to profile
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                title,
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
