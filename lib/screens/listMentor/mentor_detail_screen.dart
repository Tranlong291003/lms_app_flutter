// lib/screens/listMentor/mentor_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/config/api_config.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Giảng viên'),
        centerTitle: true,
      ),
      body: BlocBuilder<MentorDetailBloc, MentorsState>(
        builder: (context, state) {
          if (state is MentorsLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is MentorsLoaded) {
            final mentor = state.mentors.first;
            final avatarUrl =
                mentor.avatarUrl.isNotEmpty
                    ? '${ApiConfig.baseUrl}${mentor.avatarUrl}'
                    : null;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header gradient
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor,
                              theme.primaryColorDark,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Avatar with Hero
                      Positioned(
                        bottom: -60,
                        left: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.scaffoldBackgroundColor,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl:
                                  avatarUrl ??
                                  'https://www.gravatar.com/avatar/?d=mp',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              placeholder:
                                  (_, __) => Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.white,
                                    ),
                                  ),
                              errorWidget:
                                  (_, __, ___) => Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.person, size: 60),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  // Name and bio
                  Text(
                    mentor.name.isNotEmpty ? mentor.name : 'Chưa cập nhật tên',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (mentor.bio.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        mentor.bio,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Details card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              icon: Icons.phone,
                              label: 'Điện thoại',
                              value: mentor.phone,
                            ),
                            const Divider(height: 32),
                            _DetailRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: mentor.email,
                            ),
                            const Divider(height: 32),
                            _DetailRow(
                              icon: Icons.transgender,
                              label: 'Giới tính',
                              value:
                                  mentor.gender.isNotEmpty
                                      ? mentor.gender
                                      : 'Chưa cập nhật',
                            ),
                            const Divider(height: 32),
                            _DetailRow(
                              icon: Icons.calendar_today,
                              label: 'Ngày sinh',
                              value:
                                  mentor.birthdate != null
                                      ? dateFmt.format(mentor.birthdate!)
                                      : 'Chưa cập nhật',
                            ),
                            const Divider(height: 32),
                            _DetailRow(
                              icon: Icons.info,
                              label: 'Trạng thái',
                              value:
                                  mentor.isActive
                                      ? 'Hoạt động'
                                      : 'Không hoạt động',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          } else if (state is MentorsError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Widget hiển thị một dòng thông tin với icon và nhãn
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Text('$label: $value', style: theme.textTheme.bodyLarge),
        ),
      ],
    );
  }
}
