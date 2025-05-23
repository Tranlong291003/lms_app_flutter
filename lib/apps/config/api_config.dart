class ApiConfig {
  // static const String baseUrl = "http://172.20.10.5:3000";
  static const String baseUrl = "http://192.168.10.203:3000";

  // App Stats
  static String get appStats => "$baseUrl/api/app-stats";

  // users
  static String get getAllUsers => "$baseUrl/api/users";
  static String get login => "$baseUrl/api/users/login";
  static String get signUp => "$baseUrl/api/users/create";
  static String get getUserByUid => "$baseUrl/api/users";
  static String get updateUserByUid => "$baseUrl/api/users/update";
  static String get getAllMentor => "$baseUrl/api/users/listmentor";
  static String get getAllCategory => "$baseUrl/api/course-categories";
  static String get getAllCourses => "$baseUrl/api/courses";
  static String get getMentorDetail => "$baseUrl/api/users";
  static String updateUserStatus(String uid) =>
      "$baseUrl/api/users/$uid/status";
  static String checkUserActive(String uid) =>
      "$baseUrl/api/users/checkactive/$uid";

  //lesson
  static String get getAllLessons => "$baseUrl/api/lessons";
  static String getLessonsByCourseAndUser(int courseId, String userUid) =>
      "$baseUrl/api/lessons/courses/$courseId/$userUid";
  static String getLessonDetail(int lessonId) =>
      "$baseUrl/api/lessons/detail/$lessonId";
  static String updateLesson(int lessonId) =>
      "$baseUrl/api/lessons/update/$lessonId";
  static String deleteLesson(int lessonId) =>
      "$baseUrl/api/lessons/delete/$lessonId";
  static String get createLesson => "$baseUrl/api/lessons/create";
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

  // Quizzes
  static String getQuizzesByUser(String userUid) {
    final url = "$baseUrl/api/quizzes/getquizuser/$userUid";
    print('URL getQuizzesByUser: $url');
    return url;
  }

  static String getUserQuizResults(String userUid) =>
      "$baseUrl/api/quiz-results/users/$userUid/results";
  static String getQuizzesByCourseId(int courseId) =>
      "$baseUrl/api/quizzes/getquizbycoures/$courseId";
  static String get createQuiz => "$baseUrl/api/quizzes/create";
  static String updateQuiz(int quizId) => "$baseUrl/api/quizzes/update/$quizId";
  static String deleteQuiz(int quizId) => "$baseUrl/api/quizzes/delete/$quizId";

  // Questions
  static String getQuestionsByQuizId(int quizId) {
    final url = "$baseUrl/api/questions/$quizId";
    print('URL getQuestionsByQuizId: $url');
    return url;
  }

  // Quiz Results & Questions
  static String get submitQuizResult => "$baseUrl/api/quiz-results/submit";
  static String updateQuestion(int questionId) =>
      "$baseUrl/api/questions/update/$questionId";
  static String deleteQuestion(int questionId) =>
      "$baseUrl/api/questions/delete/$questionId";
  static String get createQuestionManual =>
      "$baseUrl/api/questions/createbyuser";
  static String get createQuestionAI => "$baseUrl/api/questions/createbyai";

  // Course related endpoints (excluding getAllCourses which is already there)
  static String getCoursesByInstructor(String instructorUid) =>
      "$baseUrl/api/courses/mentor/$instructorUid";
  static String updateCourse(int courseId) =>
      "$baseUrl/api/courses/update/$courseId";
  static String deleteCourse(int courseId) =>
      "$baseUrl/api/courses/delete/$courseId";
  static String get createCourse => "$baseUrl/api/courses/create";

  // Category related endpoints (excluding getAllCategory which is already there)
  static String get createCategory => "$baseUrl/api/course-categories/create";
  static String deleteCategory(int categoryId) =>
      "$baseUrl/api/course-categories/delete/$categoryId";
  static String updateCategory(int categoryId) =>
      "$baseUrl/api/course-categories/update/$categoryId";

  // Helper method để nối URL với đường dẫn ảnh
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return "";
    }

    // Nếu đã là URL đầy đủ, trả về nguyên bản
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Không đi qua server proxy nếu là placeholder.com
      if (imagePath.contains('placeholder.com')) {
        return "";
      }
      return imagePath;
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

  static String getQuizResultDetails(int resultId) =>
      '/api/quiz-results/$resultId';
}
