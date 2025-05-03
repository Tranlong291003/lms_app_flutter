import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_state.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_event.dart';
import 'package:lms/blocs/user/user_state.dart';

class ListMentorScreen extends StatelessWidget {
  const ListMentorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dispatch lần đầu khi mở màn hình
    context.read<UserBloc>().add(GetAllMentorsEvent());

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            showBack: true,
            showSearch: true,
            title: 'Danh sách giảng viên',
            onSearchChanged: (value) {
              // Gọi lại sự kiện tìm kiếm
              context.read<UserBloc>().add(GetAllMentorsEvent(search: value));
            },
          ),
          body: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is MentorsLoading) {
                return LoadingIndicator();
              }
              if (state is MentorsLoaded) {
                final mentors = state.mentors;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: mentors.length,
                  itemBuilder: (context, index) {
                    final mentor = mentors[index];
                    return Card(
                      color: theme.cardColor,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Xử lý khi nhấn vào mentor
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'mentor-${mentor.uid}',
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    mentor.avatarUrl.isNotEmpty
                                        ? mentor.avatarUrl
                                        : 'https://www.gravatar.com/avatar/?d=mp',
                                  ),
                                  onBackgroundImageError:
                                      (_, __) => const Icon(Icons.person),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name
                                    Text(
                                      mentor.name.isNotEmpty
                                          ? mentor.name
                                          : 'Không có tên',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Bio
                                    if (mentor.bio.isNotEmpty)
                                      Text(
                                        mentor.bio,
                                        style: textTheme.bodySmall,
                                      ),
                                    if (mentor.phone.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'số điện thoại: ${mentor.phone}',
                                        style: textTheme.bodySmall,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline),
                                onPressed: () {
                                  // Mở chat với mentor
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              // if (state is MentorsFailure) {
              //   return Center(child: Text(state.message));
              // }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
