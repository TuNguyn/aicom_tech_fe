class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Nail Tech App';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String authBoxName = 'auth_box';
  static const String appointmentsBoxName = 'appointments_box';
  static const String servicesBoxName = 'services_box';
  static const String customersBoxName = 'customers_box';
  static const String cacheBoxName = 'cache_box';
  static const String settingsBoxName = 'settings_box';

  // Cache keys
  static const String jwtTokenKey = 'jwt_token';
  static const String techUserKey = 'tech_user';
  static const String themeKey = 'theme_scheme';
  static const String appointmentsCachePrefix = 'appointments_';
  static const String servicesCachePrefix = 'services_';
  static const String customersCachePrefix = 'customers_';

  // Remember Me keys
  static const String rememberMeKey = 'remember_me';
  static const String savedUsernameKey = 'saved_username';
  static const String savedPasswordKey = 'saved_password';

  // Cache TTL (hours)
  static const int appointmentsCacheTTL = 1;
  static const int servicesCacheTTL = 2;
  static const int customersCacheTTL = 4;
  static const int profileCacheTTL = 24;
}
