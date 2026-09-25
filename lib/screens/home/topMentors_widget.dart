// lib/screens/home/topMentors_widget.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_dimens.dart';
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
    const defaultAvatar = 'https://www.gravatar.com/avatar/?d=mp';
    final theme = Theme.of(context);

    // Chiều cao suy ra từ nội dung (avatar + khe + một dòng nhãn) thay vì
    // `height: 90` cứng: ở cỡ chữ lớn, dòng nhãn cần thêm chỗ và khung cứng sẽ
    // cắt mất chân chữ.
    const avatarRadius = 30.0;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(fontSize: 12);
    // Đo chiều cao dòng nhãn bằng `TextPainter` thay vì nhân `fontSize * height`:
    // cách nhân đó bỏ qua `textScaler` của hệ thống và phần leading/descent mà
    // engine cộng thêm, nên dòng chữ vẫn cao hơn ước lượng một chút và `Column`
    // tràn (đã thấy tràn 0.04px trên iPhone 17 ở cỡ chữ mặc định).
    final labelPainter =
        TextPainter(
            text: TextSpan(text: 'Ag', style: labelStyle),
            textDirection: TextDirection.ltr,
            maxLines: 1,
            textScaler: MediaQuery.textScalerOf(context),
          )
          ..layout();
    final labelHeight = labelPainter.height.ceilToDouble();
    final rowHeight = avatarRadius * 2 + AppSpacing.sm + labelHeight;

    if (_randomizedMentors.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Đệm phải để avatar cuối không dính mép khi cuộn hết.
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        itemCount: _randomizedMentors.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
        itemBuilder: (context, index) {
          final mentor = _randomizedMentors[index];
          final displayName = getDisplayName(mentor.name);
          final avatarUrl =
              (mentor.avatarUrl.isNotEmpty)
                  ? ApiConfig.getImageUrl(mentor.avatarUrl)
                  : defaultAvatar;
          final imageProvider = NetworkImage(avatarUrl);

          return InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              final ctx = context;
              await precacheImage(imageProvider, ctx);
              if (!ctx.mounted) return;
              Navigator.pushNamed(
                ctx,
                AppRouter.mentorDetail,
                arguments: mentor.uid,
              );
            },
            child: Semantics(
              // Vùng chạm chỉ rộng 60px; công bố rõ đây là nút mở hồ sơ giảng
              // viên để trình đọc màn hình không đọc trơ ra tên.
              label: 'Xem hồ sơ giảng viên $displayName',
              button: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: imageProvider,
                    onBackgroundImageError: (_, __) {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: 60,
                    child: Text(
                      displayName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
