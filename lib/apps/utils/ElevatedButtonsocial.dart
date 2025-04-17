import 'package:flutter/material.dart';

ElevatedButton SocialLoginButton({
  required BuildContext context, // Tham số context
  required String assetPath, // Đường dẫn đến asset icon
  String? text, // Tham số text
  required VoidCallback onPressed, // Hàm callback khi nhấn nút
  double width = double.infinity, // Thêm tham số width với giá trị mặc định
  double height = 50, // Thêm tham số height với giá trị mặc định
  Color?
  finalIconColor, // Thêm tham số cho màu sắc của icon (nếu muốn thay đổi)
}) {
  // Nếu không truyền finalIconColor, thì màu của icon sẽ không thay đổi, giữ nguyên như lúc đầu
  Color iconColor =
      finalIconColor ??
      (Theme.of(context).brightness == Brightness.light
          ? Colors
              .black // Màu icon cho theme sáng
          : Colors.white); // Màu icon cho theme tối

  return ElevatedButton(
    onPressed: onPressed, // Gọi hàm callback khi nhấn nút
    style: ElevatedButton.styleFrom(
      minimumSize: Size(width, height), // Tuỳ chỉnh kích thước button
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Colors
                  .white // Màu nền cho theme sáng
              : Color(0xFF1F222A), // Màu nền cho theme tối
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2), // Màu viền mờ
          width: 1, // Độ dày viền
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center, // Căn giữa cả icon và text
      crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều dọc
      children: [
        Image.asset(
          assetPath, // Đường dẫn tới asset icon
          width: 20, // Chiều rộng của icon mặc định
          height: 20, // Chiều cao của icon mặc định
          color:
              finalIconColor, // Màu sắc của icon, nếu không truyền sẽ giữ nguyên
        ),
        if (text != null) ...[
          const SizedBox(width: 10), // Khoảng cách giữa icon và text
          Text(
            text, // Sử dụng text tùy chỉnh
            style: TextStyle(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors
                          .black // Màu chữ cho theme sáng
                      : Colors.white, // Màu chữ cho theme tối
            ),
          ),
        ],
      ],
    ),
  );
}
