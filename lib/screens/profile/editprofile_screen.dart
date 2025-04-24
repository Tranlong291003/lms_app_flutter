import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String fullName = 'Andrew Ainsley';
  String firstName = 'Andrew';
  DateTime? dob = DateTime(1995, 12, 27);
  String email = 'andrew_ainsley@yourdomain.com';
  String country = 'Việt Nam';
  String phone = '+84 987 654 321';
  String gender = 'Nam';
  String occupation = 'Sinh viên';

  final List<String> countryList = ['Việt Nam', 'Hoa Kỳ', 'Nhật Bản'];
  final List<String> genderList = ['Nam', 'Nữ', 'Khác'];

  Future<void> _pickDate() async {
    picker.DatePicker.showDatePicker(
      context,
      locale: picker.LocaleType.vi, // tiếng Việt
      showTitleActions: true,
      minTime: DateTime(1900),
      maxTime: DateTime.now(),
      currentTime: dob ?? DateTime.now(),
      onConfirm: (date) {
        setState(() {
          dob = date;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              _buildTextField(initialValue: fullName, hintText: 'Họ và tên'),
              _buildTextField(initialValue: firstName, hintText: 'Tên gọi'),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    initialValue:
                        dob != null
                            ? DateFormat('dd/MM/yyyy', 'vi').format(dob!)
                            : '',
                    hintText: 'Ngày sinh',
                    suffixIcon: Icons.calendar_today,
                  ),
                ),
              ),

              _buildTextField(
                initialValue: email,
                hintText: 'Email',
                suffixIcon: Icons.email,
              ),
              _buildDropdown(
                value: country,
                items: countryList,
                hint: 'Quốc gia',
                onChanged: (val) => setState(() => country = val!),
              ),
              _buildTextField(
                initialValue: phone,
                hintText: 'Số điện thoại',
                prefixIconWidget: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('🇻🇳', style: TextStyle(fontSize: 20)),
                ),
              ),
              _buildDropdown(
                value: gender,
                items: genderList,
                hint: 'Giới tính',
                onChanged: (val) => setState(() => gender = val!),
              ),
              _buildTextField(
                initialValue: occupation,
                hintText: 'Nghề nghiệp',
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Gửi thông tin cập nhật
                    print('Đã cập nhật thông tin');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Cập nhật'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required String hintText,
    IconData? suffixIcon,
    Widget? prefixIconWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIconWidget,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
