import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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

  // state tạm
  String name = '', phone = '', bio = '', avatarUrl = '';
  File? imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (!mounted || picked == null) return;

      setState(() => imageFile = File(picked.path));

      // TODO: nếu muốn tải lên server, gọi API ở đây,
      // lấy url trả về rồi setState(() => avatarUrl = newUrl);
    } catch (e) {
      debugPrint('Chọn ảnh lỗi: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể chọn ảnh')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdateSuccess) {
            context.read<UserBloc>().add(GetUserByUidEvent(state.message));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật thành công')),
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
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserLoaded) {
              final user = state.user;
              // gán lần đầu
              name = name.isEmpty ? user.name ?? '' : name;
              phone = phone.isEmpty ? user.phone ?? '' : phone;
              bio = bio.isEmpty ? user.bio ?? '' : bio;
              avatarUrl = avatarUrl.isEmpty ? user.avatarUrl ?? '' : avatarUrl;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          child: ClipOval(
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child:
                                  imageFile != null
                                      ? Image.file(
                                        imageFile!,
                                        fit: BoxFit.cover,
                                      )
                                      : avatarUrl.isNotEmpty
                                      ? Image.network(
                                        'http://192.168.10.203:3000/$avatarUrl',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) =>
                                                const Icon(Icons.person),
                                      )
                                      : Image.asset(
                                        'assets/images/avatar_placeholder.png',
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _field('Họ và tên', name, (v) => name = v),
                      _field('Số điện thoại', phone, (v) => phone = v),
                      _field('Tiểu sử', bio, (v) => bio = v, maxLines: 3),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<UserBloc>().add(
                              UpdateUserProfileEvent(
                                uid: user.uid,
                                name: name,
                                phone: phone,
                                bio: bio,
                                avatarUrl: avatarUrl,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Lưu thay đổi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('Không có dữ liệu người dùng'));
          },
        ),
      ),
    );
  }

  Widget _field(
    String label,
    String init,
    Function(String) onChanged, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: init,
        maxLines: maxLines,
        onChanged: onChanged,
        validator:
            (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
