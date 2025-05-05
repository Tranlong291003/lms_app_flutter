class ApiConfig {
  // static const String baseUrl = "http://172.20.10.5:3000";
  static const String baseUrl = "http://192.168.1.6:3000";

  // users
  static String get login => "$baseUrl/api/users/login";
  static String get signUp => "$baseUrl/api/users/create";
  static String get getUserByUid => "$baseUrl/api/users";
  static String get updateUserByUid => "$baseUrl/api/users/update";
  static String get getAllMentor => "$baseUrl/api/users/listmentor";
}
