import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/app_config.dart';
import 'core/constants/app_constants.dart';
import 'core/cache/cache_manager.dart';
import 'core/utils/toast_utils.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/app_colors.dart';
import 'presentation/providers/theme_provider.dart';
import 'app_dependencies.dart';
import 'presentation/providers/connectivity_provider.dart';
import 'presentation/widgets/connectivity_banner.dart';
import 'routes/app_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive boxes in parallel for faster startup
  await Future.wait([
    Hive.openBox<dynamic>(AppConstants.authBoxName),
    Hive.openBox<dynamic>(AppConstants.appointmentsBoxName),
    Hive.openBox<dynamic>(AppConstants.servicesBoxName),
    Hive.openBox<dynamic>(AppConstants.customersBoxName),
    Hive.openBox<dynamic>(AppConstants.cacheBoxName),
    Hive.openBox<dynamic>(AppConstants.settingsBoxName),
  ]);

  // Initialize Cache Manager
  await CacheManager.instance.init();

  // Initialize App Config
  AppConfig.init(env: Environment.dev);

  // Initialize ToastUtils
  ToastUtils.init(navigatorKey);

  // ignore: avoid_print
  print('[App] Base URL: ${AppConfig.baseUrl}');
  // ignore: avoid_print
  print('[App] Socket URL: ${AppConfig.socketUrl}');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    // Socket lifecycle management based on auth state
    ref.listen(authNotifierProvider, (_, next) {
      final socketNotifier = ref.read(socketNotifierProvider.notifier);

      if (next.isAuthenticated && next.user.token.isNotEmpty) {
        socketNotifier.connect(next.user.token, next.user.fullName);
      } else if (!next.isAuthenticated) {
        socketNotifier.disconnect();
      }
    });

    // Connectivity lifecycle management
    ref.listen<ConnectivityState>(connectivityNotifierProvider, (prev, next) {
      // Disconnect socket when going offline to stop retry loop
      if (next.isOffline) {
        ref.read(socketNotifierProvider.notifier).disconnect();
        return;
      }

      // Auto-recovery when coming back online
      if (next.justCameBackOnline) {
        final authState = ref.read(authNotifierProvider);
        if (authState.isAuthenticated && authState.user.token.isNotEmpty) {
          // Reconnect socket
          ref
              .read(socketNotifierProvider.notifier)
              .connect(authState.user.token, authState.user.fullName);
          // Reload data
          ref.read(appointmentsNotifierProvider.notifier).fetchTodayCount();
          ref.read(walkInsNotifierProvider.notifier).refreshWalkIns();
          // Reset reports so next visit fetches fresh data
          ref.invalidate(reportsNotifierProvider);
        }
      }
    });

    // Update AppColors with current theme
    AppColors.updateScheme(currentTheme);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ConnectivityBanner(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
