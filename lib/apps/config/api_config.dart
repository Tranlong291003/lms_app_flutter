class ApiConfig {
  static const String baseUrl = "http://192.168.10.203:3000";

  // users
  static String get login => "$baseUrl/api/users/login";
  static String get signUp => "$baseUrl/api/users/create";
}
