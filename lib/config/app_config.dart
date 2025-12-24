enum Environment { dev, staging, production }

class AppConfig {
  static late String baseUrl;
  static late Environment environment;

  static void init({Environment env = Environment.dev}) {
    environment = env;

    switch (env) {
      case Environment.dev:
        baseUrl = 'http://localhost:3000/api';
        break;
      case Environment.staging:
        baseUrl = 'https://staging-api.nailtech.com/api';
        break;
      case Environment.production:
        baseUrl = 'https://api.nailtech.com/api';
        break;
    }
  }
}
