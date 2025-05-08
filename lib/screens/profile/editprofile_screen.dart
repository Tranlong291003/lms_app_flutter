// lib/screens/profile/editprofile_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/blocs/cubit/notification/notification_cubit.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_event.dart';
import 'package:lms/blocs/user/user_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _bio = '';
  String? _gender;
  DateTime? _birthdate;
  File? _imageFile;
  final _picker = ImagePicker();

  static const List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (!mounted || picked == null) return;
    setState(() => _imageFile = File(picked.path));
  }

  void _pickDate() {
    final now = DateTime.now();
    final initial = _birthdate ?? DateTime(now.year - 18);
    picker.DatePicker.showDatePicker(
      context,
      locale: picker.LocaleType.vi,
      minTime: DateTime(1900),
      maxTime: now,
      currentTime: initial,
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() => _birthdate = date);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd MMMM yyyy', 'vi_VN');

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ'), centerTitle: true),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdateSuccess) {
            context.read<UserBloc>().add(GetUserByUidEvent(state.user.uid));
            final notification = state.notification;
            context.read<NotificationCubit>().showNotification(
              notification['title'],
              notification['body'],
              notification['noti_id'],
            );
            Navigator.pop(context);
          } else if (state is UserUpdateFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const LoadingIndicator();
            }
            if (state is! UserLoaded) {
              return const Center(child: Text('Không có dữ liệu người dùng'));
            }
            final user = state.user;
            // Khởi tạo các giá trị khi lần đầu build
            _name = _name.isEmpty ? user.name : _name;
            _phone = _phone.isEmpty ? user.phone : _phone;
            _bio = _bio.isEmpty ? user.bio : _bio;
            _gender ??=
                _genderOptions.contains(user.gender)
                    ? user.gender
                    : _genderOptions.first;
            _birthdate ??= user.birthdate;
            final avatarUrl =
                user.avatarUrl.startsWith('http')
                    ? user.avatarUrl
                    : '${ApiConfig.baseUrl}${user.avatarUrl}';

            return SingleChildScrollView(
              padding:
                  MediaQuery.of(context).viewInsets +
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: theme.colorScheme.surface,
                              backgroundImage:
                                  _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : (user.avatarUrl.isNotEmpty
                                              ? NetworkImage(avatarUrl)
                                              : null)
                                          as ImageProvider?,
                              child:
                                  user.avatarUrl.isEmpty && _imageFile == null
                                      ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.4),
                                      )
                                      : null,
                            ),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Thông tin cơ bản',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Họ và tên
                    _buildField(
                      'Họ và tên',
                      _name,
                      (v) => setState(() => _name = v),
                      theme,
                    ),
                    // Số điện thoại với validator mới
                    _buildField(
                      'Số điện thoại',
                      _phone,
                      (v) => setState(() => _phone = v),
                      theme,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Không được để trống';
                        }
                        final phoneRegExp = RegExp(r'^0\d{9}$');
                        if (!phoneRegExp.hasMatch(v.trim())) {
                          return 'Số điện thoại không hợp lệ (10 chữ số và bắt đầu bằng 0)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: InputDecoration(
                              labelText: 'Giới tính',
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            items:
                                _genderOptions
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => setState(() => _gender = v),
                            validator:
                                (v) =>
                                    v == null
                                        ? 'Vui lòng chọn giới tính'
                                        : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Ngày sinh',
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                _birthdate != null
                                    ? dateFmt.format(_birthdate!)
                                    : 'Chọn ngày sinh',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color:
                                      _birthdate != null
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildField(
                      'Tiểu sử',
                      _bio,
                      (v) => setState(() => _bio = v),
                      theme,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<UserBloc>().add(
                            UpdateUserProfileEvent(
                              uid: user.uid,
                              name: _name,
                              phone: _phone,
                              bio: _bio,
                              gender: _gender!,
                              birthdate: _birthdate,
                              avatarFile: _imageFile,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Lưu thay đổi'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Hàm build chung cho các field, giờ có thêm validator tuỳ chọn
  Widget _buildField(
    String label,
    String init,
    Function(String) onChanged,
    ThemeData theme, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    // Validator mặc định: không được để trống
    defaultValidator(v) =>
        v == null || v.trim().isEmpty ? 'Không được để trống' : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: init,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator ?? defaultValidator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
