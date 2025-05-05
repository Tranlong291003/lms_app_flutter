// lib/screens/home/topMentors_widget.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/routes/app_router.dart'; // import hằng số route

/// Widget hiển thị danh sách mentor ngẫu nhiên (tối đa 10), nhận dữ liệu từ parent
class TopMentors extends StatelessWidget {
  final List<User> mentors;

  const TopMentors({super.key, required this.mentors});

  String getDisplayName(String fullName) {
    final name = fullName.trim();
    if (name.isEmpty) return 'No Name';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0];
    final last = parts.last;
    final secondLast = parts[parts.length - 2];
    if (secondLast.length + last.length < 9) {
      return '$secondLast $last';
    } else {
      return last;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tạo bản sao và shuffle
    final randomList = List<User>.from(mentors)..shuffle(Random());
    // Giới hạn tối đa 10 mentors hoặc ít hơn nếu list ngắn
    final display = randomList.take(min(10, randomList.length)).toList();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: display.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final mentor = display[index];
          final displayName = getDisplayName(mentor.name);
          final avatarUrl =
              mentor.avatarUrl.isNotEmpty
                  ? '${ApiConfig.baseUrl}${mentor.avatarUrl}'
                  : 'https://www.gravatar.com/avatar/?d=mp';
          final imageProvider = NetworkImage(avatarUrl);

          return InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () async {
              // Pre-cache ảnh để chuyển mượt hơn
              await precacheImage(imageProvider, context);
              // Điều hướng sang màn MentorDetail
              Navigator.pushNamed(
                context,
                AppRouter.mentorDetail,
                arguments: mentor.uid,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: imageProvider,
                  onBackgroundImageError: (_, __) => const Icon(Icons.person),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    displayName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
