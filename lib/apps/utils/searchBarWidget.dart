import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
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
            padding: const EdgeInsets.all(8.0),
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
                  horizontal: 8,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0), // Giảm padding
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
