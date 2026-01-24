import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A reusable avatar widget with image caching support.
///
/// This widget uses CachedNetworkImage to cache avatar images and reduce
/// network requests. It includes loading states, error fallbacks, and
/// consistent styling across the app.
class CachedAvatar extends StatelessWidget {
  /// The URL of the avatar image. If null, the fallback will be shown.
  final String? imageUrl;

  /// The radius of the avatar circle.
  final double radius;

  /// Text to display as fallback (typically first letter of name).
  final String? fallbackText;

  /// Background color for the avatar.
  final Color? backgroundColor;

  /// Gradient colors for the avatar background.
  final List<Color>? gradientColors;

  /// Whether to show a loading indicator while the image loads.
  final bool showLoadingIndicator;

  /// Whether to show a shimmer effect while loading.
  final bool showShimmer;

  const CachedAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.fallbackText,
    this.backgroundColor,
    this.gradientColors,
    this.showLoadingIndicator = true,
    this.showShimmer = false,
  });

  @override
  Widget build(BuildContext context) {
    // If no URL provided, show fallback immediately
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackAvatar();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: Colors.transparent,
      ),
      placeholder: (context, url) => _buildLoadingAvatar(),
      errorWidget: (context, url, error) => _buildFallbackAvatar(),
      cacheKey: imageUrl,
      maxHeightDiskCache: 300,
      maxWidthDiskCache: 300,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  /// Builds the loading state avatar.
  Widget _buildLoadingAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ??
          (gradientColors != null
              ? gradientColors!.first.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.05)),
      child: showLoadingIndicator
          ? SizedBox(
              width: radius * 0.6,
              height: radius * 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            )
          : showShimmer
          ? _buildShimmer()
          : null,
    );
  }

  /// Builds the fallback avatar (text-based).
  Widget _buildFallbackAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: gradientColors != null
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors!,
                ),
              ),
              child: Center(child: _buildFallbackText()),
            )
          : _buildFallbackText(),
    );
  }

  /// Builds the fallback text widget.
  Widget _buildFallbackText() {
    return Text(
      fallbackText?.isNotEmpty == true ? fallbackText![0].toUpperCase() : '?',
      style: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: radius * 0.5,
      ),
    );
  }

  /// Builds a shimmer effect for loading state.
  Widget _buildShimmer() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
