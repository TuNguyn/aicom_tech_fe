import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool useWhiteBackground;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.useWhiteBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: useWhiteBackground
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'assets/icons/home.svg', 'Home'),
              _buildNavItem(1, 'assets/icons/walk_in.svg', 'Walk-In'),
              _buildNavItem(2, 'assets/icons/calendar.svg', 'Appt'),
              _buildNavItem(3, 'assets/icons/report.svg', 'Report'),
              _buildNavItem(4, 'assets/icons/more.svg', 'More'),
            ],
          ),
                ),
              ),
            )
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.85),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'assets/icons/home.svg', 'Home'),
              _buildNavItem(1, 'assets/icons/walk_in.svg', 'Walk-In'),
              _buildNavItem(2, 'assets/icons/calendar.svg', 'Appt'),
              _buildNavItem(3, 'assets/icons/report.svg', 'Report'),
              _buildNavItem(4, 'assets/icons/more.svg', 'More'),
            ],
          ),
        ),
      ),
    ),
    ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    final isSelected = currentIndex == index;
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.textSecondary.withValues(alpha: 0.5);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with Animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                height: isSelected ? 26 : 24,
                width: isSelected ? 26 : 24,
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(
                    isSelected ? activeColor : inactiveColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              // Spacing
              SizedBox(height: isSelected ? 0 : 2),
              // Text (Hidden when active)
              if (!isSelected)
                SizedBox(
                  height: 14,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: inactiveColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Dot indicator when active
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  height: 4,
                  width: 4,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}