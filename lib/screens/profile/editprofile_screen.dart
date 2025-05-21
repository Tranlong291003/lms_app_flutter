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
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_event.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/cubits/notifications/notification_cubit.dart';

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
  bool _isLoading = false;

  static const List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];

  Future<void> _pickImage() async {
    final pickerOptions = ['Chụp ảnh mới', 'Chọn từ thư viện', 'Hủy'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ...List.generate(
                pickerOptions.length,
                (index) => ListTile(
                  leading: Icon(
                    index == 0
                        ? Icons.camera_alt
                        : index == 1
                        ? Icons.photo_library
                        : Icons.cancel,
                    color:
                        index == 2
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                  ),
                  title: Text(pickerOptions[index]),
                  onTap: () async {
                    Navigator.pop(context);
                    if (index == 2) return;

                    final source =
                        index == 0 ? ImageSource.camera : ImageSource.gallery;
                    final picked = await _picker.pickImage(
                      source: source,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );

                    if (!mounted || picked == null) return;
                    setState(() => _imageFile = File(picked.path));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final dateFmt = DateFormat('dd MMMM yyyy', 'vi_VN');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        centerTitle: true,
        backgroundColor: isDark ? colorScheme.surface : colorScheme.primary,
        foregroundColor: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
        elevation: 0,
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdateSuccess) {
            setState(() => _isLoading = false);
            context.read<UserBloc>().add(GetUserByUidEvent(state.user.uid));
            final notification = state.notification;
            context.read<NotificationCubit>().showNotification(
              notification['title'],
              notification['body'],
              notification['noti_id'],
            );
            Navigator.pop(context);
          } else if (state is UserUpdateFailure) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(12),
              ),
            );
          } else if (state is UserLoading) {
            setState(() => _isLoading = true);
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading && _isLoading) {
              return const Center(child: LoadingIndicator());
            }

            if (state is! UserLoaded) {
              return const Center(child: LoadingIndicator());
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
                    : ApiConfig.getImageUrl(user.avatarUrl);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surface : colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Avatar section
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isDark
                                            ? colorScheme.onSurface.withOpacity(
                                              0.2,
                                            )
                                            : Colors.white.withOpacity(0.8),
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor:
                                      isDark
                                          ? colorScheme.surfaceContainerHighest
                                          : Colors.white.withOpacity(0.9),
                                  backgroundImage:
                                      _imageFile != null
                                          ? FileImage(_imageFile!)
                                          : (user.avatarUrl.isNotEmpty
                                                  ? NetworkImage(avatarUrl)
                                                  : null)
                                              as ImageProvider?,
                                  child:
                                      user.avatarUrl.isEmpty &&
                                              _imageFile == null
                                          ? Icon(
                                            Icons.person,
                                            size: 50,
                                            color:
                                                isDark
                                                    ? colorScheme.onSurface
                                                        .withOpacity(0.4)
                                                    : colorScheme.primary
                                                        .withOpacity(0.3),
                                          )
                                          : null,
                                ),
                              ),
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    isDark
                                        ? colorScheme.primaryContainer
                                        : Colors.white,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: colorScheme.primary,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color:
                                        isDark
                                            ? colorScheme.onPrimary
                                            : Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Cập nhật thông tin cá nhân',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color:
                                isDark ? colorScheme.onSurface : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin cá nhân',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Họ và tên
                          _buildFormField(
                            label: 'Họ và tên',
                            initialValue: _name,
                            onChanged: (v) => setState(() => _name = v),
                            icon: Icons.person_outline,
                            theme: theme,
                          ),

                          const SizedBox(height: 16),

                          // Số điện thoại
                          _buildFormField(
                            label: 'Số điện thoại',
                            initialValue: _phone,
                            onChanged: (v) => setState(() => _phone = v),
                            icon: Icons.phone_outlined,
                            theme: theme,
                            keyboardType: TextInputType.phone,
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

                          const SizedBox(height: 16),

                          // Giới tính và ngày sinh
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormDropdown(
                                  label: 'Giới tính',
                                  value: _gender,
                                  items: _genderOptions,
                                  onChanged: (v) => setState(() => _gender = v),
                                  icon: Icons.wc_outlined,
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFormDatePicker(
                                  label: 'Ngày sinh',
                                  value:
                                      _birthdate != null
                                          ? dateFmt.format(_birthdate!)
                                          : 'Chọn ngày sinh',
                                  onTap: _pickDate,
                                  icon: Icons.calendar_today_outlined,
                                  theme: theme,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Text(
                            'Giới thiệu',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildFormField(
                            label: 'Tiểu sử',
                            initialValue: _bio,
                            onChanged: (v) => setState(() => _bio = v),
                            icon: Icons.description_outlined,
                            maxLines: 4,
                            theme: theme,
                            hintText: 'Mô tả ngắn về bản thân bạn...',
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() => _isLoading = true);
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
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: isDark ? 0 : 2,
                              ),
                              child:
                                  _isLoading
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: LoadingIndicator(),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Đang lưu...'),
                                        ],
                                      )
                                      : const Text(
                                        'Lưu thay đổi',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    required IconData icon,
    required ThemeData theme,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    isDark
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          onChanged: onChanged,
          validator:
              validator ??
              ((v) =>
                  v == null || v.trim().isEmpty ? 'Không được để trống' : null),
          keyboardType: keyboardType,
          style: TextStyle(
            color:
                isDark ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color:
                  isDark
                      ? colorScheme.onSurface.withOpacity(0.5)
                      : colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            filled: true,
            fillColor:
                isDark
                    ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            errorStyle: TextStyle(color: colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildFormDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    isDark
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Vui lòng chọn giới tính' : null,
          style: TextStyle(
            color:
                isDark ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
          dropdownColor:
              isDark
                  ? colorScheme.surfaceContainerHighest
                  : theme.scaffoldBackgroundColor,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                isDark
                    ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            errorStyle: TextStyle(color: colorScheme.error),
          ),
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildFormDatePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    isDark
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
                      : colorScheme.surfaceContainerHighest.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color:
                        value == 'Chọn ngày sinh'
                            ? (isDark
                                ? colorScheme.onSurface.withOpacity(0.5)
                                : colorScheme.onSurfaceVariant.withOpacity(0.5))
                            : (isDark
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
