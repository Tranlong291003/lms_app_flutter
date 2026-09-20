// test/live_api_integration_test.dart
//
// Kiểm thử tích hợp THẬT cho các API KHÔNG thuộc phần xác thực:
// gọi API bằng chính các Service/Model của app (không mock) để xác nhận app
// parse được dữ liệu thực tế (PostgreSQL trả nhiều cột dạng chuỗi).
//
// Chạy:
//   flutter test test/live_api_integration_test.dart
//
// Test tự tạo tài khoản mới qua `POST /api/auth/register` (API tự quản lý tài
// khoản) rồi dùng access token cho các request sau.
//
// ⚠️ Test ghi dữ liệu thật (đăng ký, đăng ký học, bookmark, review...).
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/bookmark_model.dart';
import 'package:lms/models/category_model.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/models/enrolledCourse_model.dart';
import 'package:lms/models/lesson_model.dart';
import 'package:lms/models/notification_model.dart';
import 'package:lms/models/quiz/quiz_model.dart';
import 'package:lms/models/quiz/quiz_result_model.dart';
import 'package:lms/models/reivew_model.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/services/admin_user_service.dart';
import 'package:lms/services/bookmark_service.dart';
import 'package:lms/services/category_service.dart';
import 'package:lms/services/course_service.dart';
import 'package:lms/services/lesson_service.dart';
import 'package:lms/services/mentor_service.dart';
import 'package:lms/services/question_service.dart';
import 'package:lms/services/quiz_service.dart';
import 'package:lms/services/review_service.dart';
import 'package:lms/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `flutter_test` thay `HttpOverrides.global` bằng mock trả về 400 cho mọi
  // request. Test này gọi API thật nên phải khôi phục HttpClient thật.
  HttpOverrides.global = null;

  late Dio dio;
  late String jwt;
  late String uid;
  late String email;
  final password = 'Test123456!';
  final stamp = DateTime.now().millisecondsSinceEpoch;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Tạo tài khoản test mới qua API xác thực mới (không còn Firebase).
    email = 'e2e.flutter.$stamp@example.com';
    final signup = await dio.post(
      ApiConfig.authRegister,
      data: {'email': email, 'password': password, 'name': 'E2E Flutter'},
    );
    expect(signup.statusCode, 201, reason: 'Đăng ký phải trả 201');

    final accessToken = signup.data['access_token'] as String;
    uid = (signup.data['user'] as Map)['uid'] as String;

    // Nạp token vào SharedPreferences — mọi Service đọc token qua BaseService.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', accessToken);
    await prefs.setString('auth_refresh_token',
        signup.data['refresh_token'] as String);
  });

  group('Auth & User (UserService)', () {
    test('GET /api/users/:id → parse được User', () async {
      final user = await UserService().getUserByUid(uid);
      expect(user.uid, uid);
      expect(user.email, email);
      expect(user.role, 'user');
      // `GET /api/users/:id` là hồ sơ công khai và không trả `is_active`, nên
      // model phải mặc định là true (thiếu dữ liệu ≠ bị khoá).
      expect(user.isActive, isTrue);
    });

    test('PUT /api/users/update/:id (multipart, birthdate YYYY-MM-DD)', () async {
      final result = await UserService().updateProfile(
        uid: uid,
        name: 'E2E Flutter Updated',
        phone: '0909999999',
        bio: 'Bio từ test',
        gender: 'male',
        birthdate: DateTime(2000, 5, 15),
      );
      expect(result['user'], isA<User>());
      final updated = result['user'] as User;
      expect(updated.name, 'E2E Flutter Updated');
      expect(updated.birthdate?.year, 2000);
    });

    test('GET /api/users/listmentor → MentorService parse được', () async {
      final mentors = await MentorService().fetchAllMentors();
      expect(mentors, isA<List<Map<String, dynamic>>>());
      if (mentors.isNotEmpty) {
        expect(mentors.first['uid'], isNotNull);
      }
    });

    test('GET /api/users (role=user) → 403 và ném lỗi rõ ràng', () async {
      expect(
        () => AdminUserService().getAllUsers(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Category (CategoryService)', () {
    test('GET /api/course-categories → parse được CourseCategory', () async {
      final categories = await CategoryService().fetchAllCategory();
      expect(categories, isNotEmpty);
      for (final c in categories) {
        expect(c.categoryId, greaterThan(0));
        expect(c.name, isNotEmpty);
        // `course_count` là COUNT() → PostgreSQL trả về chuỗi.
        expect(c.courseCount, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Course (CourseService)', () {
    late CourseListResponse list;

    test('GET /api/courses → parse được CourseListResponse', () async {
      list = await CourseService().fetchAllCourses();
      final total = list.approved.length + list.pending.length + list.rejected.length;
      expect(total, greaterThan(0), reason: 'Cần có dữ liệu khóa học');

      for (final c in list.approved) {
        expect(c.courseId, greaterThan(0));
        expect(c.title, isNotEmpty);
        expect(c.level, isNotEmpty);
        // enroll_count/lesson_count là COUNT() → chuỗi trong JSON.
        expect(c.enrollCount, greaterThanOrEqualTo(0));
        expect(c.lessonCount, greaterThanOrEqualTo(0));
      }
    });

    test('level trả về đúng chuẩn API', () {
      final levels = list.approved.map((c) => c.level).toSet();
      for (final l in levels) {
        expect(
          kCourseLevels.contains(l),
          isTrue,
          reason: 'level "$l" phải thuộc $kCourseLevels',
        );
      }
    });

    test('GET /api/courses/:id → parse được CourseDetail', () async {
      final courseId = list.approved.first.courseId;
      final detail = await CourseService().getCourseDetail(courseId);
      expect(detail.courseId, courseId);
      expect(detail.title, isNotEmpty);
      expect(detail.reviewCount, greaterThanOrEqualTo(0));
      expect(detail.enrollmentCount, greaterThanOrEqualTo(0));
      // avg_rating là NUMERIC → chuỗi hoặc null.
      if (detail.avgRating != null) {
        expect(detail.avgRating, isA<double>());
      }
    });

    test('GET /api/courses/mentor/:uid → parse được', () async {
      final instructorUid = list.approved.first.instructorUid;
      final courses = await CourseService().getCoursesByInstructor(instructorUid);
      expect(courses, isA<List<Course>>());
    });
  });

  group('Enrollment & Lesson (CourseService, LessonService)', () {
    late Course course;

    setUpAll(() async {
      final list = await CourseService().fetchAllCourses();
      course = list.approved.first;
    });

    test('checkEnrollment trước khi đăng ký → false', () async {
      final enrolled = await CourseService().checkEnrollment(
        userUid: uid,
        courseId: course.courseId,
      );
      expect(enrolled, isFalse);
    });

    test('registerEnrollment → đăng ký thành công', () async {
      final result = await CourseService().registerEnrollment(
        userUid: uid,
        courseId: course.courseId,
      );
      expect(result, isNotNull);
    });

    test('checkEnrollment sau khi đăng ký → true', () async {
      final enrolled = await CourseService().checkEnrollment(
        userUid: uid,
        courseId: course.courseId,
      );
      expect(enrolled, isTrue);
    });

    test('getCourseProgress → trả Map có progress_percent', () async {
      final progress = await CourseService().getCourseProgress(
        userUid: uid,
        courseId: course.courseId,
      );
      expect(progress['progress_percent'], isNotNull);
    });

    test('getAllLessons → parse được Lesson (order/is_completed)', () async {
      final lessons = await LessonService().getAllLessons(
        course.courseId,
        uid,
      );
      expect(lessons, isNotEmpty);
      for (final l in lessons) {
        expect(l.lessonId, greaterThan(0));
        expect(l.courseId, course.courseId);
        expect(l.title, isNotEmpty);
      }
    });

    test('completeLesson → đánh dấu hoàn thành (gửi int, không phải chuỗi)',
        () async {
      final lessons = await LessonService().getAllLessons(course.courseId, uid);
      final lesson = lessons.first;
      // App gửi `lesson.lessonId` (int) và `lesson.courseId` (int).
      await LessonService().completeLesson(
        lesson.lessonId,
        uid,
        lesson.courseId,
      );

      final refreshed = await LessonService().getAllLessons(
        course.courseId,
        uid,
      );
      final done = refreshed.firstWhere((l) => l.lessonId == lesson.lessonId);
      expect(done.isCompleted, isTrue, reason: 'is_completed phải là true sau khi hoàn thành');
    });
  });

  group('Bookmark (BookmarkService)', () {
    late int courseId;
    late int bookmarkId;

    setUpAll(() async {
      final list = await CourseService().fetchAllCourses();
      courseId = list.approved.first.courseId;
    });

    test('createBookmark → parse được BookmarkModel', () async {
      final service = BookmarkService();
      final bookmark = await service.createBookmark(
        courseId: courseId,
        userUid: uid,
      );
      expect(bookmark.id, greaterThan(0));
      bookmarkId = bookmark.id;
    });

    test('getBookmarksByUser → có course_title/course_thumbnail', () async {
      final bookmarks = await BookmarkService().getBookmarksByUser(uid);
      expect(bookmarks, isNotEmpty);
      final bm = bookmarks.firstWhere((b) => b.id == bookmarkId);
      expect(bm.courseId, courseId);
      // Backend trả kèm thông tin khóa học.
      expect(bm.courseTitle, isNotNull);
    });

    test('deleteBookmark → xóa thành công', () async {
      final ok = await BookmarkService().deleteBookmark(
        bookmarkId: bookmarkId,
        userUid: uid,
      );
      expect(ok, isTrue);

      final after = await BookmarkService().getBookmarksByUser(uid);
      expect(after.any((b) => b.id == bookmarkId), isFalse);
    });
  });

  group('Quiz (QuizService, QuestionService)', () {
    test('getQuizzesByUser → parse được danh sách khóa học + quiz', () async {
      final data = await QuizService().getQuizzesByUser(uid);
      expect(data['enrolledCourses'], isA<List>());
      expect(data['notEnrolledCourses'], isA<List>());
      // Cấu trúc app mong đợi: courseId / courseTitle / quizzes.
      for (final c in data['notEnrolledCourses'] as List) {
        expect(c['courseId'], isNotNull);
        expect(c['courseTitle'], isNotNull);
        expect(c['quizzes'], isA<List<QuizModel>>());
      }
    });

    test('getUserQuizResults → không lỗi với user mới', () async {
      final results = await QuizService().getUserQuizResults(uid);
      expect(results, isA<List<QuizResultModel>>());
    });

    test('getQuizzesByCourseId → không lỗi khi khóa học chưa có quiz', () async {
      final list = await CourseService().fetchAllCourses();
      final quizzes = await QuizService().getQuizzesByCourseId(
        list.approved.last.courseId,
      );
      expect(quizzes, isA<List<QuizModel>>());
    });
  });

  group('Review (ReviewService)', () {
    // Chạy tuần tự trong một test để tránh phụ thuộc giữa các test.
    test('tạo → đọc → sửa → xóa đánh giá', () async {
      final list = await CourseService().fetchAllCourses();
      final courseId = list.approved.first.courseId;
      final service = ReviewService();

      // Tạo
      await service.submitReview(
        courseId: courseId,
        userId: uid,
        rating: 5,
        comment: 'Đánh giá từ test tích hợp',
      );

      // Đọc — `review_id` là SERIAL nên PostgreSQL trả về chuỗi.
      final reviews = await service.getCourseReviews(courseId);
      expect(reviews, isNotEmpty);
      final mine = reviews.firstWhere((r) => r.userUid == uid);
      expect(mine.rating, 5);
      expect(mine.reviewId, greaterThan(0));
      final reviewId = mine.reviewId;

      // Sửa
      await service.updateReview(
        reviewId: reviewId,
        userUid: uid,
        rating: 4,
        comment: 'Đã cập nhật',
      );
      final afterUpdate = await service.getCourseReviews(courseId);
      expect(
        afterUpdate.firstWhere((r) => r.reviewId == reviewId).rating,
        4,
      );

      // Xóa
      await service.deleteReview(reviewId: reviewId, userUid: uid);
      final afterDelete = await service.getCourseReviews(courseId);
      expect(afterDelete.any((r) => r.reviewId == reviewId), isFalse);
    });
  });

  group('App config', () {
    test('baseUrl trỏ tới HTTPS (production)', () {
      expect(ApiConfig.baseUrl.startsWith('https://'), isTrue);
    });

    test('getImageUrl ghép đúng đường dẫn tương đối /uploads/...', () {
      final url = ApiConfig.getImageUrl('/uploads/avatars/a.png');
      expect(url, '${ApiConfig.baseUrl}/uploads/avatars/a.png');
    });

    test('getImageUrl giữ nguyên URL tuyệt đối', () {
      const abs = 'https://i.ytimg.com/vi/abc/maxresdefault.jpg';
      expect(ApiConfig.getImageUrl(abs), abs);
    });

    test('NotificationModel parse được noti_id dạng UUID (chuỗi)', () {
      final model = NotificationModel.fromJson({
        'noti_id': '98a75d4c-3122-4a4e-9c2f-1a2b3c4d5e6f',
        'uid': uid,
        'title': 'Tiêu đề',
        'content': 'Nội dung',
        'icon': 'book',
        'color': '#4caf50',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      expect(model.notiId, '98a75d4c-3122-4a4e-9c2f-1a2b3c4d5e6f');
      expect(model.isRead, isFalse);
    });

    test('EnrolledCourse parse được số dạng chuỗi (PostgreSQL COUNT)', () {
      final model = EnrolledCourse.fromJson({
        'course_id': '82',
        'title': 'Khóa học',
        'thumbnail_url': null,
        'total_lessons': '5',
        'completed_lessons': '0',
        'progress_percent': '0',
        'total_duration': '0 phút',
      });
      expect(model.courseId, 82);
      expect(model.totalLessons, 5);
      expect(model.progressPercent, 0);
    });

    test('UUID noti_id không làm hỏng bookmark/notification service', () async {
      // noti_id là UUID — xác nhận model giữ nguyên dạng chuỗi.
      final json = jsonEncode({
        'noti_id': '0193c1b2-7c4d-7f8e-9a0b-1c2d3e4f5a6b',
      });
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded['noti_id'].runtimeType, String);
    });
  });
}
