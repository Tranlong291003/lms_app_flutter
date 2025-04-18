import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15), // Bo góc cho thanh tìm kiếm
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.grey[200]
                : Color(0xFF1F222A), // Màu nền cho thanh tìm kiếm
      ),
      child: Row(
        children: [
          // Biểu tượng tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.search,
              color: Colors.grey, // Màu biểu tượng tìm kiếm
            ),
          ),
          // TextField cho phần nhập tìm kiếm
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                ), // Màu chữ nhạt cho hint
                border: InputBorder.none, // Loại bỏ viền
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                ), // Đảm bảo không có khoảng cách thừa
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: IconButton(
              icon: Image.asset('assets/icons/filter.png'),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
