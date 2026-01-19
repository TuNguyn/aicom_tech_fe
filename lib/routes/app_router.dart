import 'package:aicom_tech_fe/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/pages/auth/splash_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/store_selection_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/notifications/notifications_page.dart';
import '../presentation/providers/auth_provider.dart';
import 'app_routes.dart';

// Listenable that notifies when auth state changes (only for isAuthenticated)
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(this._ref) {
    _ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // Only notify when isAuthenticated changes
      if (previous?.isAuthenticated != next.isAuthenticated) {
        notifyListeners();
      }
    });
  }

  final Ref _ref;

  bool get isAuthenticated => _ref.read(authNotifierProvider).isAuthenticated;
}

final authChangeNotifierProvider = Provider<AuthChangeNotifier>((ref) {
  return AuthChangeNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = ref.watch(authChangeNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authChangeNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authChangeNotifier.isAuthenticated;
      final isAuthRoute = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.storeSelection,
      ].contains(state.matchedLocation);

      // If authenticated and on auth pages, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      // If not authenticated and not on auth pages, redirect to splash
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.splash;
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.storeSelection,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StoreSelectionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide in from right when entering
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var slideTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var slideAnimation = animation.drive(slideTween);

            // Fade in effect
            var fadeAnimation = animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: Curves.easeIn),
              ),
            );

            // Slide out to left when exiting (when another page is pushed)
            var secondarySlideAnimation = secondaryAnimation.drive(
              Tween(begin: Offset.zero, end: const Offset(-0.3, 0.0)).chain(
                CurveTween(curve: curve),
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: secondarySlideAnimation,
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start from right
            const end = Offset.zero; // End at current position
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      ),
    ],
  );
});
