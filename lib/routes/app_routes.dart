class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String splash = '/';
  static const String login = '/login';

  // Main routes
  static const String home = '/home';
  static const String notifications = '/home/notifications';
  static const String appointments = '/home/appointments';
  static const String serviceTracker = '/home/service-tracker';
  static const String customerDetail = '/home/customers/:id';
  static const String profile = '/home/profile';
  static const String settings = '/home/settings';
  static const String themeSelector = '/home/settings/theme';

  // Helper methods
  static String getCustomerDetailPath(int id) => '/home/customers/$id';
}
