import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/cubits/mentor_request_cubit.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';

class MentorRequestScreen extends StatefulWidget {
  const MentorRequestScreen({super.key});

  @override
  State<MentorRequestScreen> createState() => _MentorRequestScreenState();
}

class _MentorRequestScreenState extends State<MentorRequestScreen> {
  XFile? _pickedFile;

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) setState(() => _pickedFile = file);
  }

  void _removeImage() => setState(() => _pickedFile = null);

  void _submit() {
    final state = context.read<UserBloc>().state;
    if (state is! UserLoaded) return;
    if (_pickedFile == null) {
      CustomSnackBar.showError(
        context: context,
        message: 'Vui lòng gửi file ảnh minh chứng!',
      );
      return;
    }
    context.read<MentorRequestCubit>().sendMentorRequest(
      userUid: state.user.uid,
      imageFile: File(_pickedFile!.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return BlocConsumer<MentorRequestCubit, MentorRequestState>(
      listener: (context, state) {
        if (!mounted) return;
        if (state is MentorRequestSuccess) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Gửi yêu cầu thành công!',
          );
          _removeImage();
        } else if (state is MentorRequestError) {
          final msg = state.message.toLowerCase();
          if (msg.contains('đã gửi yêu cầu') ||
              msg.contains('đang chờ duyệt')) {
            CustomSnackBar.showWarning(
              context: context,
              message: 'Bạn đã gửi rồi và đang chờ admin duyệt!',
            );
          } else {
            CustomSnackBar.showError(context: context, message: state.message);
          }
        }
      },
      builder: (context, state) {
        final loading = state is MentorRequestLoading;
        return Scaffold(
          backgroundColor: c.surface,
          appBar: AppBar(
            title: const Text('Đăng ký Mentor'),
            centerTitle: true,
            backgroundColor: c.surface,
            elevation: 0,
            foregroundColor: c.onSurface,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header minh họa
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [c.primary, c.primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Trở thành Mentor cùng LMS',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chia sẻ kiến thức, tạo thu nhập và phát triển cộng đồng học tập cùng chúng tôi!',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Quyền lợi
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.primaryContainer.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quyền lợi khi là Mentor:',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _benefitRow('Tạo & quản lý khoá học'),
                        _benefitRow('Nhận thu nhập từ học viên'),
                        _benefitRow('Xây dựng thương hiệu cá nhân'),
                        _benefitRow('Kết nối cộng đồng chuyên gia'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Upload ảnh
                  Text(
                    'Ảnh minh chứng (bắt buộc):',
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  _pickedFile == null
                      ? OutlinedButton.icon(
                        onPressed: loading ? null : _pickImage,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: c.primary, width: 1.4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(Icons.upload_rounded, color: c.primary),
                        label: Text(
                          'Tải ảnh lên',
                          style: TextStyle(
                            color: c.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      : Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              File(_pickedFile!.path),
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                          GestureDetector(
                            onTap: loading ? null : _removeImage,
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  const SizedBox(height: 36),
                  // Nút gửi yêu cầu
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: loading ? null : _submit,
                      icon:
                          loading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: LoadingIndicator(),
                              )
                              : const Icon(Icons.send_rounded),
                      label: Text(
                        loading ? 'Đang gửi...' : 'Gửi yêu cầu Mentor',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _benefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
