import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';

/// Chặn truy cập màn hình theo role.
///
/// Dùng ở tầng router để người dùng không thể vào `/admin/*` hay `/mentor/*`
/// bằng cách gõ tay route. Guard chỉ chặn **điều hướng** — các nút/tab dành cho
/// admin hoặc mentor vẫn phải được ẩn theo role ở tầng UI.
class RoleGuard extends StatelessWidget {
  /// Các role được phép vào [child] (`user` | `mentor` | `admin`).
  final List<String> allowedRoles;
  final Widget child;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthCubit>().state.role;

    // Chưa biết role (đang khôi phục phiên): chờ thay vì hiện màn "không có
    // quyền" — nếu không, người dùng hợp lệ sẽ thấy báo lỗi trong tích tắc.
    if (role == null || role.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!allowedRoles.contains(role)) {
      return const _AccessDeniedScreen();
    }

    return child;
  }
}

class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Không có quyền truy cập')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Bạn không có quyền truy cập trang này',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.home,
                  (route) => false,
                ),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
