import 'package:aicom_tech_fe/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/pages/auth/splash_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/home/home_page.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final isAuthenticated = authState.isAuthenticated;

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoginRoute = [
        AppRoutes.splash,
        AppRoutes.login,
      ].contains(state.matchedLocation);

      // If authenticated and on login pages, redirect to home
      if (isAuthenticated && isLoginRoute) {
        return AppRoutes.home;
      }

      // If not authenticated and not on login pages, redirect to splash
      if (!isAuthenticated && !isLoginRoute) {
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
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
});
