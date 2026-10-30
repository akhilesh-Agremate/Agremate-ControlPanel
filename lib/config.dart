class Environments {
  static const String production = 'prod', dev = 'dev', sandbox = 'sandbox';
}

class ConfigEnvironments {
  static const String _currentEnvironments = String.fromEnvironment(
    'environment',
    defaultValue: 'dev',
  );
  // static const String _currentEnvironments = String.fromEnvironment(
  //   'environment',
  //   defaultValue: 'prod',
  // );
  // String.fromEnvironment('environment', defaultValue: 'sandbox');
  static final List<Map<String, String>> _availableEnvironments = [
    {
      'env': Environments.dev,
      'url': '',
      'baseUrl': 'https://api-dev.app.agremate.com',
      'authBaseUrl': 'https://api-dev.app.agremate.com',
      'envFile': 'assets/.env.sandbox',
    },
    {
      'env': Environments.production,
      'url': '',
      'baseUrl': 'https://api-core.app.agremate.com',
      'authBaseUrl': 'https://api-auth.app.agremate.com',
      'envFile': 'assets/.env.prod',
    },
    {
      'env': Environments.sandbox,
      'url': '',
      'baseUrl': 'https://core-preprod.app.agremate.com',
      'authBaseUrl': 'https://api-preprod.app.agremate.com',
      'envFile': 'assets/.env.sandbox',
    },
  ];
  static Map<String, String> getEnvironments() {
    return _availableEnvironments.firstWhere(
          (d) => d['env'] == _currentEnvironments,
    );
  }
}