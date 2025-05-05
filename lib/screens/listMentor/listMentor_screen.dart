// lib/screens/listMentor/listMentor_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/blocs/mentors/mentors_bloc.dart';
import 'package:lms/blocs/mentors/mentors_event.dart';
import 'package:lms/blocs/mentors/mentors_state.dart';
import 'package:lms/models/user_model.dart';
import 'package:shimmer/shimmer.dart';

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
              return const Center(child: Text('Chưa có giảng viên nào.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MentorsBloc>().add(GetAllMentorsEvent());
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: mentors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder:
                    (context, index) => _MentorListItem(mentor: mentors[index]),
              ),
            );
          }
          return const SizedBox.shrink();
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
            ? '${ApiConfig.baseUrl}${mentor.avatarUrl}'
            : null;

    final imageProvider =
        avatarUrl != null
            ? CachedNetworkImageProvider(avatarUrl)
            : const AssetImage('assets/images/default_avatar.png')
                as ImageProvider;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Pre-cache avatar
          if (avatarUrl != null) {
            await precacheImage(imageProvider, context);
          }
          Navigator.pushNamed(context, '/mentordetail', arguments: mentor.uid);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl:
                      avatarUrl ?? 'https://www.gravatar.com/avatar/?d=mp',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  placeholder:
                      (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
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
                        color: Colors.grey.shade200,
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
                  if (avatarUrl != null) {
                    await precacheImage(imageProvider, context);
                  }
                  Navigator.pushNamed(
                    context,
                    '/mentordetail',
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
