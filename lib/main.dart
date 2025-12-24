import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/app_config.dart';
import 'core/constants/app_constants.dart';
import 'core/cache/cache_manager.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/app_colors.dart';
import 'presentation/providers/theme_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive boxes
  await Hive.openBox<dynamic>(AppConstants.authBoxName);
  await Hive.openBox<dynamic>(AppConstants.appointmentsBoxName);
  await Hive.openBox<dynamic>(AppConstants.servicesBoxName);
  await Hive.openBox<dynamic>(AppConstants.customersBoxName);
  await Hive.openBox<dynamic>(AppConstants.cacheBoxName);
  await Hive.openBox<dynamic>(AppConstants.settingsBoxName);

  // Initialize Cache Manager
  await CacheManager.instance.init();

  // Initialize App Config
  AppConfig.init(env: Environment.dev);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    // Update AppColors with current theme
    AppColors.updateScheme(currentTheme);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
