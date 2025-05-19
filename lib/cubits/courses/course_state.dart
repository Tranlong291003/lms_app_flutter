// lib/blocs/cubit/courses/course_state.dart
part of 'course_cubit.dart';

/// Lớp cơ sở cho tất cả các trạng thái của danh sách khóa học
abstract class CourseState extends Equatable {
  const CourseState();
  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo khi chưa tải danh sách khóa học
class CourseInitial extends CourseState {
  const CourseInitial();
}

/// Trạng thái đang tải danh sách khóa học
class CourseLoading extends CourseState {
  const CourseLoading();
}

/// Trạng thái đã tải xong danh sách khóa học
class CourseLoaded extends CourseState {
  /// Danh sách tất cả khóa học
  final List<Course> courses;

  /// Danh sách khóa học được chọn ngẫu nhiên
  final List<Course> randomCourses;

  /// Danh sách khóa học đã được phê duyệt
  final List<Course> approvedCourses;

  /// Danh sách khóa học đang chờ phê duyệt
  final List<Course> pendingCourses;

  /// Danh sách khóa học đã bị từ chối
  final List<Course> rejectedCourses;

  const CourseLoaded(
    this.courses,
    this.randomCourses, {
    this.approvedCourses = const [],
    this.pendingCourses = const [],
    this.rejectedCourses = const [],
  });

  @override
  List<Object?> get props => [
    courses,
    randomCourses,
    approvedCourses,
    pendingCourses,
    rejectedCourses,
  ];
}

/// Trạng thái lỗi khi tải danh sách khóa học
class CourseError extends CourseState {
  /// Thông báo lỗi
  final String message;
  const CourseError(this.message);
  @override
  List<Object?> get props => [message];
}
