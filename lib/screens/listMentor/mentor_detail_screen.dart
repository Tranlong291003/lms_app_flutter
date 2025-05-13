// lib/screens/listMentor/mentor_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/FeInDevMessaage.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/blocs/mentors/mentor_detail_bloc.dart';
import 'package:lms/blocs/mentors/mentors_event.dart';
import 'package:lms/blocs/mentors/mentors_state.dart';
import 'package:shimmer/shimmer.dart';

/// Màn hình chi tiết Mentor, chỉ cần truyền UID
class MentorDetailScreen extends StatefulWidget {
  final String uid;
  const MentorDetailScreen({super.key, required this.uid});

  @override
  _MentorDetailScreenState createState() => _MentorDetailScreenState();
}

class _MentorDetailScreenState extends State<MentorDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MentorDetailBloc>().add(GetMentorByUidEvent(widget.uid));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd MMMM yyyy', 'vi_VN');
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<MentorDetailBloc, MentorsState>(
        builder: (context, state) {
          if (state is MentorsLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is MentorsLoaded) {
            final mentor = state.mentors.first;
            final avatarUrl =
                mentor.avatarUrl.isNotEmpty
                    ? ApiConfig.getImageUrl(mentor.avatarUrl)
                    : null;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar with background and avatar
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  stretch: true,
                  backgroundColor: colorScheme.surface,
                  leading: Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary.withOpacity(0.8),
                                colorScheme.primary,
                                colorScheme.primary.withBlue(
                                  colorScheme.primary.blue + 20,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Overlay pattern for visual interest
                        Opacity(
                          opacity: 0.05,
                          child: Image.network(
                            'https://www.transparenttextures.com/patterns/cubes.png',
                            repeat: ImageRepeat.repeat,
                          ),
                        ),
                        // Decorative circles for modern design
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -80,
                          left: -80,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        // Bottom gradient overlay for text readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 120,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        // Avatar and name at bottom
                        Positioned(
                          bottom: 24,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              // Avatar with border
                              Hero(
                                tag: 'mentor_avatar_${mentor.uid}',
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: colorScheme.surface,
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            avatarUrl ??
                                            'https://www.gravatar.com/avatar/?d=mp',
                                        width: 140,
                                        height: 140,
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration.zero,
                                        fadeOutDuration: Duration.zero,
                                        placeholder:
                                            (_, __) => Shimmer.fromColors(
                                              baseColor:
                                                  isDark
                                                      ? Colors.grey.shade800
                                                      : Colors.grey.shade300,
                                              highlightColor:
                                                  isDark
                                                      ? Colors.grey.shade700
                                                      : Colors.grey.shade100,
                                              child: Container(
                                                width: 140,
                                                height: 140,
                                                color:
                                                    isDark
                                                        ? Colors.grey.shade900
                                                        : Colors.white,
                                              ),
                                            ),
                                        errorWidget:
                                            (_, __, ___) => Container(
                                              width: 140,
                                              height: 140,
                                              color:
                                                  isDark
                                                      ? Colors.grey.shade800
                                                      : Colors.grey.shade200,
                                              child: Icon(
                                                Icons.person,
                                                size: 70,
                                                color:
                                                    isDark
                                                        ? Colors.grey.shade600
                                                        : Colors.grey.shade400,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Name with shadow for readability
                              Text(
                                mentor.name.isNotEmpty
                                    ? mentor.name
                                    : 'Chưa cập nhật tên',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Status badge
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            mentor.isActive
                                ? (isDark
                                    ? Colors.green.shade900.withOpacity(0.2)
                                    : Colors.green.shade50)
                                : (isDark
                                    ? Colors.red.shade900.withOpacity(0.2)
                                    : Colors.red.shade50),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color:
                              mentor.isActive
                                  ? (isDark
                                      ? Colors.green.shade400
                                      : Colors.green.shade300)
                                  : (isDark
                                      ? Colors.red.shade400
                                      : Colors.red.shade300),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            mentor.isActive
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            color:
                                mentor.isActive
                                    ? (isDark
                                        ? Colors.green.shade400
                                        : Colors.green.shade700)
                                    : (isDark
                                        ? Colors.red.shade400
                                        : Colors.red.shade700),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mentor.isActive
                                ? 'Đang hoạt động'
                                : 'Không hoạt động',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color:
                                  mentor.isActive
                                      ? (isDark
                                          ? Colors.green.shade400
                                          : Colors.green.shade700)
                                      : (isDark
                                          ? Colors.red.shade400
                                          : Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bio section
                if (mentor.bio.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3)
                                : colorScheme.surfaceContainerHighest
                                    .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isDark
                                  ? colorScheme.outline.withOpacity(0.1)
                                  : colorScheme.outline.withOpacity(0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Giới thiệu',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            mentor.bio,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Information section
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDark
                                  ? Colors.black12
                                  : Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Thông tin cá nhân',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        _InfoItem(
                          icon: Icons.phone_outlined,
                          label: 'Điện thoại',
                          value:
                              mentor.phone.isNotEmpty
                                  ? mentor.phone
                                  : 'Chưa cập nhật',
                        ),
                        _InfoItem(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value:
                              mentor.email.isNotEmpty
                                  ? mentor.email
                                  : 'Chưa cập nhật',
                        ),
                        _InfoItem(
                          icon: Icons.transgender_outlined,
                          label: 'Giới tính',
                          value:
                              mentor.gender.isNotEmpty
                                  ? mentor.gender
                                  : 'Chưa cập nhật',
                        ),
                        _InfoItem(
                          icon: Icons.calendar_today_outlined,
                          label: 'Ngày sinh',
                          value:
                              mentor.birthdate != null
                                  ? dateFmt.format(mentor.birthdate!)
                                  : 'Chưa cập nhật',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // Contact button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: ElevatedButton.icon(
                      onPressed:
                          mentor.isActive
                              ? () {
                                showFeatureInDevelopmentMessage(
                                  context,
                                  'Liên hệ giảng viên',
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.message_outlined),
                      label: const Text(
                        'Liên hệ giảng viên',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is MentorsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: colorScheme.error, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Đã xảy ra lỗi',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MentorDetailBloc>().add(
                        GetMentorByUidEvent(widget.uid),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Widget hiển thị một mục thông tin cá nhân
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.brightness == Brightness.dark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(indent: 60, height: 1),
      ],
    );
  }
}
