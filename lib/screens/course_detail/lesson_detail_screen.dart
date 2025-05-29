import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/apps/utils/youtube_video_player.dart';
import 'package:lms/cubits/lessons/lesson_detail_cubit.dart';
import 'package:lms/cubits/lessons/lesson_detail_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonDetailScreen extends StatefulWidget {
  final int lessonId;
  final int? courseId;

  const LessonDetailScreen({super.key, required this.lessonId, this.courseId});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool isFullScreen = false;
  YoutubePlayerController? _controller;
  String? _currentVideoId;
  bool _hasCompleted = false;
  bool _isStateLoaded = false;
  late final LessonDetailCubit _lessonDetailCubit;
  final _auth = FirebaseAuth.instance;

  String get _userUid => _auth.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    print('[LessonDetailScreen] ▶️ initState');
    print('[LessonDetailScreen] 📝 LessonId: ${widget.lessonId}');
    if (widget.courseId != null) {
      print('[LessonDetailScreen] 📝 CourseId từ tham số: ${widget.courseId}');
    }
    _lessonDetailCubit = LessonDetailCubit();
    _lessonDetailCubit.stream.listen(_onStateChanged);
    _loadLessonDetail();
  }

  void _onStateChanged(LessonDetailState state) {
    print('[LessonDetailScreen] 📝 State changed: $state');
    if (state is LessonDetailLoaded) {
      setState(() {
        _isStateLoaded = true;
      });
    } else {
      setState(() {
        _isStateLoaded = false;
      });
    }
  }

  void _loadLessonDetail() async {
    print('[LessonDetailScreen] ▶️ Bắt đầu tải chi tiết bài học');
    await _lessonDetailCubit.loadLessonDetail(widget.lessonId);
    print('[LessonDetailScreen] ✅ Đã gọi loadLessonDetail');
  }

  void _initController(String videoId, {bool autoPlay = false}) {
    if (_controller != null && _currentVideoId == videoId) return;
    print('[LessonDetailScreen] ▶️ Khởi tạo controller cho video: $videoId');

    _controller?.dispose();
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: autoPlay,
        mute: false,
        enableCaption: false,
        showLiveFullscreenButton: true,
        controlsVisibleAtStart: true,
        useHybridComposition: true,
        forceHD: false,
        hideThumbnail: false,
      ),
    );
    _controller?.addListener(_videoListener);
    _currentVideoId = videoId;
    print('[LessonDetailScreen] ✅ Đã khởi tạo controller thành công');
  }

  void _videoListener() {
    if (_controller == null || !_isStateLoaded) return;

    final duration = _controller!.metadata.duration.inSeconds;
    final currentPosition = _controller!.value.position.inSeconds;
    final progress = (currentPosition / duration * 100).toStringAsFixed(1);

    // In ra tiến độ video mỗi 10%
    if (currentPosition % (duration / 10).round() < 1) {
      print('[LessonDetailScreen] 📊 Tiến độ video: $progress%');
      print(
        '[LessonDetailScreen] 📝 Thời gian hiện tại: $currentPosition giây',
      );
      print('[LessonDetailScreen] 📝 Tổng thời gian: $duration giây');
    }

    // Nếu video đã phát được 90% và chưa đánh dấu hoàn thành
    if (currentPosition >= duration * 0.9 && !_hasCompleted) {
      print('[LessonDetailScreen] 🎯 Video đã phát được $progress%');
      print('[LessonDetailScreen] 📝 Bắt đầu đánh dấu hoàn thành');
      print('[LessonDetailScreen] 📝 LessonId: ${widget.lessonId}');
      print('[LessonDetailScreen] 📝 UserUid: $_userUid');

      // Kiểm tra state trước khi gọi completeLesson
      final state = _lessonDetailCubit.state;
      if (state is LessonDetailLoaded) {
        print('[LessonDetailScreen] ✅ State hợp lệ, đang đánh dấu hoàn thành');

        // Lấy courseId từ lesson
        final courseId = state.lesson.courseId;
        print('[LessonDetailScreen] 📝 CourseId từ lesson: $courseId');

        _hasCompleted = true;
        _lessonDetailCubit.completeLesson(widget.lessonId, _userUid, courseId);
      } else {
        print('[LessonDetailScreen] ⚠️ State không hợp lệ: $state');
        print('[LessonDetailScreen] ⚠️ Không thể đánh dấu hoàn thành');
      }
    }
  }

  void enterFullScreen() {
    setState(() => isFullScreen = true);
    Future.delayed(Duration.zero, () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
  }

  void exitFullScreen() {
    setState(() => isFullScreen = false);
    Future.delayed(Duration.zero, () {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    _lessonDetailCubit.close();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar:
          isFullScreen
              ? null
              : AppBar(
                automaticallyImplyLeading: false, // ẩn nút back
                title: Text(
                  'Chi tiết bài học',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color:
                        isDark ? colorScheme.onSurface : colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor:
                    isDark ? colorScheme.surface : colorScheme.primary,
                iconTheme: IconThemeData(
                  color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
                ),
                elevation: isDark ? 0 : 2,
              ),
      body: BlocProvider.value(
        value: _lessonDetailCubit,
        child: BlocBuilder<LessonDetailCubit, LessonDetailState>(
          builder: (context, state) {
            print('[LessonDetailScreen] 📝 Current state: $state');

            if (state is LessonDetailLoading) {
              _isStateLoaded = false;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Đang tải bài học...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is LessonDetailError) {
              _isStateLoaded = false;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không thể tải bài học',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadLessonDetail,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is LessonDetailLoaded) {
              _isStateLoaded = true;
              final lesson = state.lesson;
              print('[LessonDetailScreen] 📝 Loaded lesson: ${lesson.title}');

              if (lesson.videoId != null && lesson.videoId!.isNotEmpty) {
                _initController(lesson.videoId!);
              }

              if (isFullScreen) {
                return Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubeVideoPlayer(
                      videoId: lesson.videoId ?? '',
                      autoPlay: false,
                      onEnterFullScreen: enterFullScreen,
                      onExitFullScreen: exitFullScreen,
                      controller: _controller,
                    ),
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  // Video Section
                  if (lesson.videoId != null && lesson.videoId!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: YoutubeVideoPlayer(
                          videoId: lesson.videoId!,
                          onEnterFullScreen: enterFullScreen,
                          onExitFullScreen: exitFullScreen,
                          controller: _controller,
                        ),
                      ),
                    ),

                  // Lesson Info Section
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3)
                                : colorScheme.primary.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tiêu đề và trạng thái
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  lesson.title,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (state.isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Đã hoàn thành',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Thông tin bổ sung
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _buildInfoChip(
                                context,
                                Icons.access_time,
                                'Thời lượng: ${lesson.videoDuration ?? _formatDuration(_controller?.metadata.duration.inSeconds ?? 0)}',
                              ),
                              _buildInfoChip(
                                context,
                                Icons.calendar_today,
                                'Ngày tạo: ${DateFormat('dd/MM/yyyy').format(lesson.createdAt)}',
                              ),
                              _buildInfoChip(
                                context,
                                Icons.folder,
                                'Khóa học ID: ${lesson.courseId}',
                              ),
                              _buildInfoChip(
                                context,
                                Icons.sort,
                                'Thứ tự: ${lesson.order}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Nội dung bài học
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tiêu đề nội dung
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? colorScheme.primaryContainer
                                          .withOpacity(0.3)
                                      : colorScheme.primaryContainer
                                          .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Nội dung bài học',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Nội dung chính
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  isDark ? colorScheme.surface : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow:
                                  isDark
                                      ? []
                                      : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              border:
                                  isDark
                                      ? Border.all(
                                        color: colorScheme.outline.withOpacity(
                                          0.1,
                                        ),
                                        width: 1,
                                      )
                                      : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  lesson.content ?? '',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),

                                // Tài liệu đính kèm (nếu có)
                                if (lesson.pdfUrl != null ||
                                    lesson.slideUrl != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 24),
                                      Text(
                                        'Tài liệu đính kèm',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (lesson.pdfUrl != null)
                                        _buildAttachmentItem(context, {
                                          'name': 'Tài liệu PDF',
                                          'url':
                                              '${ApiConfig.baseUrl}${lesson.pdfUrl}',
                                          'type': 'pdf',
                                        }),
                                      if (lesson.slideUrl != null)
                                        _buildAttachmentItem(context, {
                                          'name': 'Slide bài giảng',
                                          'url':
                                              '${ApiConfig.baseUrl}${lesson.slideUrl}',
                                          'type': 'ppt',
                                        }),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Nút đánh dấu hoàn thành (nếu chưa hoàn thành)
                  if (!state.isCompleted)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _lessonDetailCubit.completeLesson(
                              widget.lessonId,
                              _userUid,
                              lesson.courseId,
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Đánh dấu đã hoàn thành'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Khoảng trống cuối cùng
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDark
                ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
                : colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(
    BuildContext context,
    Map<String, dynamic> attachment,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final String fileName = attachment['name'] ?? 'Tài liệu';
    final String fileUrl = attachment['url'] ?? '';
    final String fileType =
        attachment['type'] ?? fileName.split('.').last.toLowerCase();

    IconData fileIcon;
    Color iconColor;

    switch (fileType) {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        fileIcon = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'xls':
      case 'xlsx':
        fileIcon = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case 'ppt':
      case 'pptx':
        fileIcon = Icons.slideshow;
        iconColor = Colors.orange;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        fileIcon = Icons.image;
        iconColor = Colors.purple;
        break;
      default:
        fileIcon = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            isDark
                ? colorScheme.surfaceContainerHighest.withOpacity(0.2)
                : colorScheme.surfaceContainerHighest.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isDark
                  ? colorScheme.outline.withOpacity(0.1)
                  : colorScheme.outline.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(fileIcon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (attachment['size'] != null)
                  Text(
                    _formatFileSize(attachment['size']),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              if (fileUrl.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không tìm thấy đường dẫn tải xuống'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final Uri url = Uri.parse(fileUrl);
                if (!await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                )) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không thể mở đường dẫn tải xuống'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi tải xuống: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.download),
            color: colorScheme.primary,
            tooltip: 'Tải xuống',
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
