class ApiConfig {
  // static const String baseUrl = "http://172.20.10.5:3000";
  static const String baseUrl = "http://192.168.10.203:3000";

  // users
  static String get login => "$baseUrl/api/users/login";
  static String get signUp => "$baseUrl/api/users/create";
  static String get getUserByUid => "$baseUrl/api/users";
  static String get updateUserByUid => "$baseUrl/api/users/update";
  static String get getAllMentor => "$baseUrl/api/users/listmentor";
  static String get getAllCategory => "$baseUrl/api/course-categories";
  static String get getAllCourses => "$baseUrl/api/courses";
  static String get getMentorDetail => "$baseUrl/api/users";

  //lesson
  static String get getAllLessons => "$baseUrl/api/lessons";
  static String getLessonsByCourseAndUser(int courseId, String userUid) =>
      "$baseUrl/api/lessons/courses/$courseId/$userUid";
  static String getLessonDetail(int lessonId) =>
      "$baseUrl/api/lessons/detail/$lessonId";

  static String get completeLesson => "$baseUrl/api/lessons/complete";

  static String checkEnrollment(String userUid, int courseId) =>
      "$baseUrl/api/enrollments/check/$userUid/$courseId";

  static String get registerEnrollment => "$baseUrl/api/enrollments/register";

  // enrolled courses
  static String getEnrolledCoursesByUser(String userUid) =>
      "$baseUrl/api/enrollments/user/$userUid";

  // bookmarks
  static String getBookmarksByUser(String userUid) {
    final url = "$baseUrl/api/bookmarks/$userUid";
    print('URL getBookmarksByUser: $url');
    return url;
  }

  static String get createBookmark {
    final url = "$baseUrl/api/bookmarks/create";
    print('URL createBookmark: $url');
    return url;
  }

  static String get deleteBookmark {
    final url = "$baseUrl/api/bookmarks/delete";
    print('URL deleteBookmark: $url');
    return url;
  }

  // Helper method để nối URL với đường dẫn ảnh
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return baseUrl;
    }

    // Đảm bảo imagePath không bắt đầu bằng / nếu baseUrl đã kết thúc bằng /
    if (imagePath.startsWith('/') && baseUrl.endsWith('/')) {
      return baseUrl + imagePath.substring(1);
    }

    // Đảm bảo có dấu / giữa baseUrl và imagePath
    if (!imagePath.startsWith('/') && !baseUrl.endsWith('/')) {
      return "$baseUrl/$imagePath";
    }

    return baseUrl + imagePath;
  }
}
