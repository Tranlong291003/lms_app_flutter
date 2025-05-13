// lib/screens/home/topMentors_widget.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart'; // import hằng số route
import 'package:lms/models/user_model.dart';

/// Widget hiển thị danh sách mentor ngẫu nhiên (tối đa 10), nhận dữ liệu từ parent
class TopMentors extends StatefulWidget {
  final List<User> mentors;

  const TopMentors({super.key, required this.mentors});

  @override
  State<TopMentors> createState() => _TopMentorsState();
}

class _TopMentorsState extends State<TopMentors> {
  late final List<User> _randomizedMentors;

  @override
  void initState() {
    super.initState();
    // Random và cache danh sách mentors khi widget được khởi tạo
    final randomList = List<User>.from(widget.mentors)..shuffle(Random());
    _randomizedMentors = randomList.take(min(10, randomList.length)).toList();
  }

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
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _randomizedMentors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final mentor = _randomizedMentors[index];
          final displayName = getDisplayName(mentor.name);
          final avatarUrl = ApiConfig.getImageUrl(mentor.avatarUrl);
          final imageProvider = NetworkImage(avatarUrl);

          return InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () async {
              await precacheImage(imageProvider, context);
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
                  backgroundColor: Colors.transparent,
                  backgroundImage: imageProvider,
                  onBackgroundImageError:
                      (_, __) =>
                          const Icon(Icons.person, color: Colors.transparent),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    displayName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                      fontSize: 12,
                    ),
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
