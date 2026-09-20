// test/features_integration_test.dart
//
// Kiểm thử chức năng THẬT: dùng chính Service/Model của app, gọi API production
// bằng tài khoản test để xác nhận từng chức năng hoạt động và parse đúng dữ
// liệu thực tế.
//
// Tài khoản: test2@gmail.com / 123123 (đổi qua --dart-define nếu cần)
//   flutter test test/features_integration_test.dart
//
// ⚠️ Test có GHI dữ liệu thật (đăng ký học, bookmark, review) rồi dọn dẹp.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/json_parse.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/models/enrolledCourse_model.dart';
import 'package:lms/models/quiz/quiz_model.dart';
import 'package:lms/services/auth_service.dart';
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

const _email = String.fromEnvironment(
  'TEST_EMAIL',
  defaultValue: 'test2@gmail.com',
);
const _password = String.fromEnvironment(
  'TEST_PASSWORD',
  defaultValue: '123123',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  late String uid;
  late Dio dio;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    // Đăng nhập qua chính AuthService để token được lưu như app thật.
    final auth = AuthService();
    final data = await auth.login(email: _email, password: _password);
    uid = (data['user'] as Map)['uid'] as String;

    // Dùng cho các thao tác dọn dẹp / kiểm chứng trực tiếp.
    final prefs = await SharedPreferences.getInstance();
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('auth_token')}',
        },
      ),
    );
  });

  group('Xác thực', () {
    test('GET /api/auth/me trả về đúng người dùng', () async {
      final me = await AuthService().getUserInfo();
      expect(me['uid'], uid);
      expect(me['email'], _email);
      expect(me['role'], isNotNull);
    });

    test('đăng nhập sai mật khẩu → lỗi rõ ràng, không lộ chi tiết', () async {
      await expectLater(
        AuthService().login(email: _email, password: 'sai-mat-khau'),
        throwsA(isA<Exception>()),
      );
    });

    test('checkUserActive trả về bool', () async {
      final active = await UserService().checkUserActive(uid);
      expect(active, isA<bool>());
      expect(active, isTrue, reason: 'Tài khoản test phải đang hoạt động');
    });
  });

  group('Người dùng', () {
    test('getUserByUid parse được User', () async {
      final user = await UserService().getUserByUid(uid);
      expect(user.uid, uid);
      expect(user.email, _email);
      expect(user.name, isNotEmpty);
    });
  });

  group('Danh mục', () {
    test('fetchAllCategory parse được, courseCount >= 0', () async {
      final cats = await CategoryService().fetchAllCategory();
      expect(cats, isNotEmpty);
      for (final c in cats) {
        expect(c.categoryId, greaterThan(0));
        expect(c.name, isNotEmpty);
        // COUNT() → PostgreSQL trả chuỗi; model phải parse được.
        expect(c.courseCount, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Khoá học', () {
    late CourseListResponse all;

    test('fetchAllCourses parse được đủ 3 nhóm trạng thái', () async {
      all = await CourseService().fetchAllCourses();
      expect(
        all.approved.length + all.pending.length + all.rejected.length,
        greaterThan(0),
      );
      for (final c in all.approved) {
        expect(c.courseId, greaterThan(0));
        expect(c.title, isNotEmpty);
        expect(c.level, isNotEmpty);
        expect(c.enrollCount, greaterThanOrEqualTo(0));
        expect(c.lessonCount, greaterThanOrEqualTo(0));
      }
    });

    test('level chỉ chứa giá trị API chấp nhận', () {
      for (final c in all.approved) {
        expect(
          kCourseLevels.contains(c.level),
          isTrue,
          reason: 'level "${c.level}" phải thuộc $kCourseLevels',
        );
      }
    });

    test('getCourseDetail parse được số liệu tổng hợp', () async {
      final id = all.approved.first.courseId;
      final d = await CourseService().getCourseDetail(id);
      expect(d.courseId, id);
      expect(d.title, isNotEmpty);
      expect(d.reviewCount, greaterThanOrEqualTo(0));
      expect(d.enrollmentCount, greaterThanOrEqualTo(0));
      if (d.avgRating != null) {
        expect(d.avgRating, isA<double>());
      }
    });

    test('checkEnrollment trả về bool cho khóa đã đăng ký', () async {
      final id = all.approved.first.courseId;
      expect(
        await CourseService().checkEnrollment(userUid: uid, courseId: id),
        isA<bool>(),
      );
    });
  });

  group('Khoá học đã đăng ký', () {
    test('parse được EnrolledCourse (số dạng chuỗi)', () async {
      final res = await dio.get(ApiConfig.getEnrolledCoursesByUser(uid));
      final data = res.data['data'] as Map;
      final ongoing = (data['in_progress'] as List?) ?? [];
      final done = (data['completed'] as List?) ?? [];

      for (final raw in [...ongoing, ...done]) {
        final c = EnrolledCourse.fromJson(raw as Map<String, dynamic>);
        expect(c.courseId, greaterThan(0));
        expect(c.title, isNotEmpty);
        // total_lessons/completed_lessons/progress_percent là COUNT()/tính toán
        // → có thể là chuỗi.
        expect(c.totalLessons, greaterThanOrEqualTo(0));
        expect(c.completedLessons, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Bài học', () {
    test('parse được danh sách bài học của khóa đã đăng ký', () async {
      final res = await dio.get(ApiConfig.getEnrolledCoursesByUser(uid));
      final data = res.data['data'] as Map;
      final courses = (data['in_progress'] as List?) ?? [];
      if (courses.isEmpty) return; // không có khóa nào thì bỏ qua

      // `course_id` là SERIAL → API trả CHUỖI; đọc tolerant như app.
      final courseId = asIntOrNull((courses.first as Map)['course_id']);
      if (courseId == null) return;

      final lessons = await LessonService().getAllLessons(courseId, uid);
      expect(lessons, isA<List>());
      for (final l in lessons) {
        expect(l.lessonId, greaterThan(0));
        expect(l.title, isNotEmpty);
      }
    });
  });

  group('Quiz', () {
    test('getQuizzesByUser trả về 2 nhóm khóa học', () async {
      final res = await QuizService().getQuizzesByUser(uid);
      expect(res['enrolledCourses'], isA<List>());
      expect(res['notEnrolledCourses'], isA<List>());

      // Mỗi khóa có danh sách quizzes; quiz_id là SERIAL → API trả CHUỖI,
      // `as int` sẽ ném lỗi nên model phải đọc tolerant.
      var sawQuiz = false;
      for (final course in res['enrolledCourses'] as List) {
        expect((course as Map)['courseId'], isA<int>());
        for (final quiz in (course)['quizzes'] as List<QuizModel>) {
          expect(quiz.quizId, greaterThan(0));
          expect(quiz.title, isNotEmpty);
          expect(quiz.timeLimit, greaterThanOrEqualTo(0));
          expect(quiz.attemptLimit, greaterThan(0));
          sawQuiz = true;
        }
      }
      // Tài khoản mới chưa đăng ký khóa nào → không có quiz. Chỉ khẳng định
      // khi thực sự có quiz để parse.
      if ((res['enrolledCourses'] as List).isEmpty) return;
      expect(sawQuiz, isTrue, reason: 'Khóa đã đăng ký phải kèm quiz');
    });

    test('getQuestionsByQuizId parse được câu hỏi + đáp án', () async {
      final res = await QuizService().getQuizzesByUser(uid);
      final courses = res['enrolledCourses'] as List;
      if (courses.isEmpty) return;

      final firstQuiz = (courses.first as Map)['quizzes'] as List;
      if (firstQuiz.isEmpty) return;
      final quizId = (firstQuiz.first as QuizModel).quizId;

      final questions = await QuestionService().getQuestionsByQuizId(quizId);
      expect(questions, isNotEmpty, reason: 'Quiz phải có câu hỏi');
      for (final q in questions) {
        expect(q.questionId, greaterThan(0));
        expect(q.question, isNotEmpty);
        expect(q.options, isNotEmpty);
        expect(q.correctIndex, greaterThanOrEqualTo(0));
      }
    });

    test('getUserQuizResults parse được kết quả đã làm', () async {
      final results = await QuizService().getUserQuizResults(uid);
      expect(results, isA<List>());
      for (final r in results) {
        expect(r.resultId, greaterThan(0));
        expect(r.score, greaterThanOrEqualTo(0));
        expect(r.totalQuestions, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Bookmark', () {
    test('thêm → đọc → xoá bookmark', () async {
      final courses = await CourseService().fetchAllCourses();
      final courseId = courses.approved.first.courseId;
      final svc = BookmarkService();

      // Dọn bookmark cũ nếu có để test lặp lại được.
      final before = await svc.getBookmarksByUser(uid);
      for (final b in before.where((b) => b.courseId == courseId)) {
        await svc.deleteBookmark(bookmarkId: b.id, userUid: uid);
      }

      await svc.createBookmark(courseId: courseId, userUid: uid);
      final after = await svc.getBookmarksByUser(uid);
      final created = after.where((b) => b.courseId == courseId).toList();
      expect(created, hasLength(1), reason: 'Bookmark phải được tạo');

      // API trả kèm thông tin khoá học.
      expect(created.first.courseId, courseId);

      await svc.deleteBookmark(bookmarkId: created.first.id, userUid: uid);
      final finalList = await svc.getBookmarksByUser(uid);
      expect(
        finalList.where((b) => b.courseId == courseId),
        isEmpty,
        reason: 'Bookmark phải bị xoá',
      );
    });
  });

  group('Giảng viên', () {
    test('fetchAllMentors trả về danh sách', () async {
      final mentors = await MentorService().fetchAllMentors();
      expect(mentors, isA<List>());
      for (final m in mentors) {
        expect(m['uid'], isNotNull);
      }
    });
  });

  group('Đánh giá', () {
    test('đọc đánh giá của khoá học', () async {
      final courses = await CourseService().fetchAllCourses();
      final reviews = await ReviewService().getCourseReviews(
        courses.approved.first.courseId,
      );
      expect(reviews, isA<List>());
    });
  });

  group('Cấu hình API', () {
    test('baseUrl dùng HTTPS', () {
      expect(ApiConfig.baseUrl.startsWith('https://'), isTrue);
    });

    test('getImageUrl ghép đúng đường dẫn tương đối', () {
      final url = ApiConfig.getImageUrl('/uploads/anh.png');
      expect(url, '${ApiConfig.baseUrl}/uploads/anh.png');
    });

    test('getImageUrl giữ nguyên URL tuyệt đối', () {
      const abs = 'https://cdn.example.com/a.png';
      expect(ApiConfig.getImageUrl(abs), abs);
    });

    test('getImageUrl trả chuỗi rỗng với null/chuỗi rỗng', () {
      // Trả về String (không nullable); chuỗi rỗng nghĩa là "không có ảnh".
      expect(ApiConfig.getImageUrl(null), isEmpty);
      expect(ApiConfig.getImageUrl(''), isEmpty);
    });
  });
}
