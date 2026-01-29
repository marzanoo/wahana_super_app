class ApiConfig {
  static const String baseUrl = 'http://124.243.134.244/superapp/api';

  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';

  static String get logoutUrl => '$baseUrl$logoutEndpoint';
  static String get loginUrl => '$baseUrl$loginEndpoint';

}
