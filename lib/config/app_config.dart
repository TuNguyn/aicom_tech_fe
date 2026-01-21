enum Environment { dev, staging, production }

class AppConfig {
  static late String baseUrl;
  static late String socketUrl;
  static late Environment environment;

  static void init({Environment env = Environment.dev}) {
    environment = env;

    switch (env) {
      case Environment.dev:
        baseUrl = 'http://172.232.3.34:3002';
        socketUrl = 'http://172.232.3.34:3002/events';
        break;
      case Environment.staging:
        baseUrl = 'https://staging-api.nailtech.com/api';
        socketUrl = 'https://staging-api.nailtech.com/events';
        break;
      case Environment.production:
        baseUrl = 'https://api.nailtech.com/api';
        socketUrl = 'https://api.nailtech.com/events';
        break;
    }
  }
}
