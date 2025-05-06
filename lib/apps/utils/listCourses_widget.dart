import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/blocs/cubit/courses/course_cubit.dart';
import 'package:lms/models/courses/courses_model.dart';

class ListCoursesWidget extends StatelessWidget {
  const ListCoursesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseCubit, CourseState>(
      builder: (context, state) {
        if (state is CourseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CourseLoaded) {
          return _buildList(state.courses);
        } else if (state is CourseError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildList(List<Course> courses) {
    final formatter = NumberFormat('#,###');
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final course = courses[index];
        final int actualPrice =
            course.discountPrice > 0 ? course.discountPrice : course.price;

        return Container(
          height: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color(0xFF1F222A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      course.thumbnailUrl ?? '',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (ctx, _, __) => Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              _tag(
                                course.categoryName,
                                const Color(0xFFE6ECFD),
                                const Color(0xFF2F56DD),
                              ),
                              const SizedBox(width: 8),
                              _tag(
                                course.level,
                                _getLevelColor(course.level),
                                Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "${formatter.format(actualPrice)} VND",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F56DD),
                                ),
                              ),
                              if (course.discountPrice > 0) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "${formatter.format(course.price)} VND",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: BookmarkButton(initialSaved: false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
    );
  }

  static Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'cơ bản':
        return Colors.green.shade400;
      case 'trung cấp':
        return Colors.orange.shade400;
      case 'nâng cao':
        return Colors.red.shade400;
      default:
        return Colors.grey;
    }
  }
}

class BookmarkButton extends StatefulWidget {
  final bool initialSaved;
  const BookmarkButton({super.key, this.initialSaved = false});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    isSaved = widget.initialSaved;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isSaved ? Icons.bookmark : Icons.bookmark_border,
        color: const Color(0xFF2F56DD),
      ),
      onPressed: () => setState(() => isSaved = !isSaved),
    );
  }
}
