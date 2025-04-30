import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/blocs/cubit/notification_cubit.dart'; // Import NotificationCubit
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_event.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '', phone = '', bio = '';
  File? imageFile;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (!mounted || picked == null) return;
    setState(() => imageFile = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdateSuccess) {
            context.read<UserBloc>().add(GetUserByUidEvent(state.user.uid));

            // Hiển thị thông báo cục bộ sau khi cập nhật thành công
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
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: theme.colorScheme.primary,
                  size: 60,
                ),
              );
            }
            if (state is! UserLoaded) {
              return const Center(child: Text('Không có dữ liệu người dùng'));
            }

            final user = state.user;
            name = name.isEmpty ? user.name ?? '' : name;
            phone = phone.isEmpty ? user.phone ?? '' : phone;
            bio = bio.isEmpty ? user.bio ?? '' : bio;
            final avatarPath = user.avatarUrl ?? '';

            return SingleChildScrollView(
              padding:
                  MediaQuery.of(context).viewInsets + const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    /* ----------------- Avatar ----------------- */
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // ① ẢNH (giữ nguyên như trước)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor:
                                    theme.colorScheme.secondaryContainer,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 140,
                                    height: 140,
                                    child:
                                        imageFile != null
                                            ? Image.file(
                                              imageFile!,
                                              fit: BoxFit.cover,
                                            )
                                            : avatarPath.isNotEmpty
                                            ? Image.network(
                                              'http://192.168.10.203:3000$avatarPath',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) => const Icon(
                                                    Icons.person,
                                                    size: 48,
                                                  ),
                                            )
                                            : const Icon(
                                              Icons.person,
                                              size: 48,
                                            ),
                                  ),
                                ),
                              ),
                            ),

                            // ② ICON góc phải-dưới
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded, // hoặc Icons.edit
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Text(
                      'Thông tin cơ bản',
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _field('Họ và tên', name, (v) => name = v, theme),
                    _field('Số điện thoại', phone, (v) => phone = v, theme),
                    _field('Tiểu sử', bio, (v) => bio = v, theme, maxLines: 3),
                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<UserBloc>().add(
                            UpdateUserProfileEvent(
                              uid: user.uid,
                              name: name,
                              phone: phone,
                              bio: bio,
                              avatarFile: imageFile, // null nếu không đổi
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Lưu thay đổi'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _field(
    String label,
    String init,
    Function(String) onChanged,
    ThemeData theme, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        initialValue: init,
        maxLines: maxLines,
        onChanged: onChanged,
        validator:
            (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
