import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String labelText; // Văn bản nhãn (label)
  final bool obscureText; // Kiểm soát việc ẩn/hiện văn bản
  final TextEditingController controller; // Điều khiển giá trị của TextField
  final bool showVisibilityIcon; // Xác định có hiển thị icon ẩn/hiện không
  final String? prefixAsset; // Asset phía trước trường nhập liệu

  const CustomTextField({
    super.key,
    required this.labelText,
    this.obscureText = false, // Mặc định không ẩn văn bản
    required this.controller,
    this.showVisibilityIcon = false, // Mặc định không hiển thị icon ẩn/hiện
    this.prefixAsset, // Cho phép người dùng truyền asset prefix
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscure; // Biến để kiểm soát việc ẩn/hiện văn bản

  @override
  void initState() {
    super.initState();
    _isObscure =
        widget.obscureText; // Thiết lập trạng thái ẩn/hiện khi khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller, // Sử dụng controller truyền vào
      obscureText: _isObscure, // Kiểm tra xem văn bản có bị ẩn hay không
      decoration: InputDecoration(
        labelText: widget.labelText, // Sử dụng labelText được truyền vào
        // Nếu không truyền prefixAsset thì mặc định dùng icon email cho trường email hoặc icon khóa cho mật khẩu
        prefixIcon:
            widget.prefixAsset != null
                ? Image.asset(
                  widget.prefixAsset!,
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                )
                : const Icon(
                  Icons.email,
                ), // Mặc định dùng icon email nếu không có asset
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Bo góc
          borderSide: const BorderSide(
            color: Colors.grey, // Màu viền
            width: 1, // Độ dày viền
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Bo góc khi focus
          borderSide: const BorderSide(
            color: Colors.blue, // Màu viền khi focus
            width: 1.5, // Độ dày viền khi focus
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Bo góc khi bình thường
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.5), // Màu viền mờ
            width: 1, // Độ dày viền khi bình thường
          ),
        ),
        // Kiểm tra xem có muốn hiển thị icon ẩn/hiện hay không
        suffixIcon:
            widget.showVisibilityIcon
                ? IconButton(
                  icon: Icon(
                    _isObscure
                        ? Icons.visibility_off
                        : Icons.visibility, // Icon thay đổi khi nhấn
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure =
                          !_isObscure; // Đổi trạng thái ẩn/hiện văn bản
                    });
                  },
                )
                : null, // Nếu không có, không hiển thị icon ẩn/hiện
      ),
    );
  }
}
