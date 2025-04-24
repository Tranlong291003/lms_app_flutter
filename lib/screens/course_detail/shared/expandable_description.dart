import 'package:flutter/material.dart';

class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({super.key});

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _expanded = false;

  final String _text =
      'Khoá học này sẽ cung cấp cho bạn kiến thức cơ bản đến nâng cao về thiết kế giao diện người dùng và trải nghiệm người dùng. '
      'Bạn sẽ học cách tạo ra các giao diện đẹp mắt, dễ sử dụng và tối ưu cho người dùng.';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _expanded || _text.length <= 120
              ? _text
              : '${_text.substring(0, 120)}...',
          textAlign: TextAlign.justify,
          style: const TextStyle(fontSize: 14),
        ),
        if (_text.length > 120)
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Thu gọn' : 'Xem thêm...',
              style: TextStyle(color: Colors.blue[600]),
            ),
          ),
      ],
    );
  }
}
