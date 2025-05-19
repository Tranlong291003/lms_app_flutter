part of 'course_cubit.dart';

/// Lớp cơ sở cho tất cả các trạng thái chi tiết khóa học
abstract class CourseDetailState extends Equatable {
  const CourseDetailState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu trước khi tải thông tin chi tiết khóa học
class CourseDetailInitial extends CourseDetailState {}

/// Trạng thái đang tải thông tin chi tiết khóa học
class CourseDetailLoading extends CourseDetailState {}

/// Trạng thái đã tải xong thông tin chi tiết khóa học
class CourseDetailLoaded extends CourseDetailState {
  /// Thông tin chi tiết khóa học
  final CourseDetail detail;

  const CourseDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

/// Trạng thái lỗi khi tải thông tin chi tiết khóa học
class CourseDetailError extends CourseDetailState {
  /// Thông báo lỗi
  final String message;

  const CourseDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
