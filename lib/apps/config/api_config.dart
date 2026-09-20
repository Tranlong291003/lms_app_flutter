class ApiConfig {
  /// Địa chỉ backend. Mặc định là môi trường production (Vercel), có thể ghi đè
  /// khi chạy app trỏ về backend local:
  ///
  /// ```
  /// flutter run --dart-define=API_BASE_URL=http://192.168.10.203:3000
  /// ```
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://online-learning-api.vercel.app',
  );

  /// Thời gian chờ tối đa cho mỗi request (giây).
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Auth (API tự quản lý tài khoản — KHÔNG dùng Firebase Auth)
  static String get authLogin => "$baseUrl/api/auth/login";
  static String get authRegister => "$baseUrl/api/auth/register";
  static String get authRefresh => "$baseUrl/api/auth/refresh";
  static String get authMe => "$baseUrl/api/auth/me";
  static String get authLogout => "$baseUrl/api/auth/logout";
  static String get authChangePassword => "$baseUrl/api/auth/change-password";
  static String get authForgotPassword => "$baseUrl/api/auth/forgot-password";
  static String get authResetPassword => "$baseUrl/api/auth/reset-password";

  // App Stats
  static String get appStats => "$baseUrl/api/app-stats";

  // users
  static String get getAllUsers => "$baseUrl/api/users";
  static String get login => "$baseUrl/api/users/login";
  static String get signUp => "$baseUrl/api/users/create";
  static String get getUserByUid => "$baseUrl/api/users";
  static String get updateUserByUid => "$baseUrl/api/users/update";
  static String get getAllMentor => "$baseUrl/api/users/listmentor";
  static String get updateUserRole => "$baseUrl/api/users/updaterole";
  static String get deleteUser => "$baseUrl/api/users/delete";
  static String get getAllCategory => "$baseUrl/api/course-categories";
  static String get getAllCourses => "$baseUrl/api/courses";
  static String get getMentorDetail => "$baseUrl/api/users";
  static String updateUserStatus(String uid) =>
      "$baseUrl/api/users/$uid/status";
  static String checkUserActive(String uid) =>
      "$baseUrl/api/users/checkactive/$uid";
  static String deleteUserById(String uid) => "$baseUrl/api/users/delete/$uid";

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

  /// Tiến độ học của người dùng trong một khóa học.
  static String getCourseProgress({required String userUid, required int courseId}) =>
      "$baseUrl/api/enrollments/progress?userUid=$userUid&courseId=$courseId";

  static String deleteEnrollment(int enrollmentId) =>
      "$baseUrl/api/enrollments/delete/$enrollmentId";

  // enrolled courses
  static String getEnrolledCoursesByUser(String userUid) =>
      "$baseUrl/api/enrollments/user/$userUid";

  // bookmarks
  static String getBookmarksByUser(String userUid) =>
      "$baseUrl/api/bookmarks/$userUid";

  static String get createBookmark => "$baseUrl/api/bookmarks/create";

  static String get deleteBookmark => "$baseUrl/api/bookmarks/delete";

  // Quizzes
  static String getQuizzesByUser(String userUid) =>
      "$baseUrl/api/quizzes/getquizuser/$userUid";

  static String getUserQuizResults(String userUid) =>
      "$baseUrl/api/quiz-results/users/$userUid/results";
  static String getQuizzesByCourseId(int courseId) =>
      "$baseUrl/api/quizzes/getquizbycourse/$courseId";
  static String get createQuiz => "$baseUrl/api/quizzes/create";
  static String updateQuiz(int quizId) => "$baseUrl/api/quizzes/update/$quizId";
  static String deleteQuiz(int quizId) => "$baseUrl/api/quizzes/delete/$quizId";

  // Questions
  static String getQuestionsByQuizId(int quizId) =>
      "$baseUrl/api/questions/$quizId";

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
  static String updateCourseStatus(int courseId) =>
      "$baseUrl/api/courses/$courseId/status";

  // Category related endpoints (excluding getAllCategory which is already there)
  static String get createCategory => "$baseUrl/api/course-categories/create";
  static String deleteCategory(int categoryId) =>
      "$baseUrl/api/course-categories/delete/$categoryId";
  static String updateCategory(int categoryId) =>
      "$baseUrl/api/course-categories/update/$categoryId";

  // Reviews
  static String getCourseReviews(int courseId) =>
      "$baseUrl/api/reviews/course/$courseId";
  static String get createReview => "$baseUrl/api/reviews/create";
  static String updateReview(int reviewId) =>
      "$baseUrl/api/reviews/update/$reviewId";
  static String deleteReview(int reviewId) =>
      "$baseUrl/api/reviews/delete/$reviewId";

  // Notifications
  static String get notifications => "$baseUrl/api/notifications";
  static String get markNotificationRead =>
      "$baseUrl/api/notifications/mark-read";
  static String deleteNotification(String notiId) =>
      "$baseUrl/api/notifications/delete/$notiId";

  // Mentor requests
  static String get mentorRequest => "$baseUrl/api/mentor-requests";
  static String mentorRequestStatus(int id) =>
      "$baseUrl/api/mentor-requests/$id/status";

  /// Chi tiết một lượt làm bài (bao gồm đáp án đúng và giải thích).
  static String getQuizResultDetails(int resultId) =>
      "$baseUrl/api/quiz-results/$resultId";

  /// Chấm điểm bài tự luận (mentor/admin).
  static String gradeQuizResult(int resultId) =>
      "$baseUrl/api/quiz-results/quiz-results/$resultId/grade";

  /// Helper method để nối URL với đường dẫn ảnh
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
}
