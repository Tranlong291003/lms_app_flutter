// lib/screens/listMentor/listMentor_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/blocs/mentors/mentors_bloc.dart';
import 'package:lms/blocs/mentors/mentors_event.dart';
import 'package:lms/blocs/mentors/mentors_state.dart';
import 'package:lms/models/user_model.dart';
import 'package:shimmer/shimmer.dart';

/// Màu ngữ nghĩa của theme hiện tại.
AppColors _c(BuildContext context) => AppColors.of(context);

const defaultAvatar = 'https://www.gravatar.com/avatar/?d=mp';

class ListMentorScreen extends StatefulWidget {
  const ListMentorScreen({super.key});

  @override
  _ListMentorScreenState createState() => _ListMentorScreenState();
}

class _ListMentorScreenState extends State<ListMentorScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch chỉ một lần sau khi widget đã mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MentorsBloc>().add(GetAllMentorsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        showBack: true,
        showSearch: true,
        title: 'Danh sách giảng viên',
        onSearchChanged: (value) {
          // Vẫn cho phép tìm kiếm, sẽ dispatch mỗi khi search thay đổi
          context.read<MentorsBloc>().add(GetAllMentorsEvent(search: value));
        },
      ),
      body: BlocBuilder<MentorsBloc, MentorsState>(
        builder: (context, state) {
          if (state is MentorsLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is MentorsLoaded) {
            final mentors = state.mentors;
            if (mentors.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.person_search_outlined,
                title: 'Chưa có giảng viên nào',
                message: 'Danh sách giảng viên sẽ xuất hiện ở đây.',
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MentorsBloc>().add(RefreshMentorsEvent());
              },
              child: ListView.separated(
                padding: listPaddingWithBottomInset(context, all: 12),
                itemCount: mentors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder:
                    (context, index) => _MentorListItem(mentor: mentors[index]),
              ),
            );
          }
          // `MentorsError` và trạng thái chưa xác định trước đây trả
          // `SizedBox.shrink()` → danh sách TRỐNG im lặng, không báo lỗi cũng
          // không có cách thử lại.
          if (state is MentorsError) {
            return EmptyStateWidget(
              icon: Icons.cloud_off_rounded,
              title: 'Không tải được danh sách giảng viên',
              message: state.message,
              isError: true,
              actionLabel: 'Thử lại',
              onAction: () =>
                  context.read<MentorsBloc>().add(GetAllMentorsEvent()),
            );
          }
          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }
}

class _MentorListItem extends StatelessWidget {
  final User mentor;
  const _MentorListItem({required this.mentor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final avatarUrl =
        mentor.avatarUrl.isNotEmpty
            ? ApiConfig.getImageUrl(mentor.avatarUrl)
            : defaultAvatar;

    final imageProvider = CachedNetworkImageProvider(avatarUrl);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Pre-cache avatar
          await precacheImage(imageProvider, context);
          Navigator.pushNamed(
            context,
            AppRouter.mentorDetail,
            arguments: mentor.uid,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  placeholder:
                      (_, __) => Shimmer.fromColors(
                        baseColor: _c(context).neutral,
                        highlightColor: _c(context).neutral,
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.white,
                        ),
                      ),
                  errorWidget:
                      (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: _c(context).neutral,
                        child: const Icon(Icons.person, size: 30),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor.name.isNotEmpty ? mentor.name : 'Không có tên',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (mentor.bio.isNotEmpty)
                      Text(
                        mentor.bio,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                color: primary,
                onPressed: () async {
                  await precacheImage(imageProvider, context);
                  Navigator.pushNamed(
                    context,
                    AppRouter.mentorDetail,
                    arguments: mentor.uid,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
