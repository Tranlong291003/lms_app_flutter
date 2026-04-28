import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String labelText; // Văn bản nhãn (label)
  final bool obscureText; // Kiểm soát việc ẩn/hiện văn bản
  final TextEditingController controller; // Điều khiển giá trị của TextField
  final bool showVisibilityIcon; // Xác định có hiển thị icon ẩn/hiện không
  final String? prefixAsset; // Asset phía trước trường nhập liệu
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.obscureText = false, // Mặc định không ẩn văn bản
    required this.controller,
    this.showVisibilityIcon = false, // Mặc định không hiển thị icon ẩn/hiện
    this.prefixAsset, // Cho phép người dùng truyền asset prefix
    this.validator,
    this.keyboardType,
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
    final theme = Theme.of(context);
    return TextFormField(
      cursorColor: theme.colorScheme.primary,
      controller: widget.controller, // Sử dụng controller truyền vào
      obscureText: _isObscure, // Kiểm tra xem văn bản có bị ẩn hay không
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText, // Sử dụng labelText được truyền vào
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        // Nếu không truyền prefixAsset thì mặc định dùng icon email cho trường email hoặc icon khóa cho mật khẩu
        prefixIcon:
            widget.prefixAsset != null
                ? Image.asset(
                  widget.prefixAsset!,
                  color: theme.colorScheme.primary,
                  width: 20,
                  height: 20,
                )
                : Icon(
                  Icons.email,
                  color: theme.colorScheme.primary,
                ), // Mặc định dùng icon email nếu không có asset
        // Kiểm tra xem có muốn hiển thị icon ẩn/hiện hay không
        suffixIcon:
            widget.showVisibilityIcon
                ? IconButton(
                  icon: Icon(
                    _isObscure
                        ? Icons.visibility_off
                        : Icons.visibility, // Icon thay đổi khi nhấn
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure =
                          !_isObscure; // Đổi trạng thái ẩn/hiện văn bản
                    });
                  },
                )
                : null, // Nếu không có, không hiển thị icon ẩn/hiện
        errorStyle: TextStyle(color: theme.colorScheme.error, fontSize: 12),
      ),
    );
  }
}
