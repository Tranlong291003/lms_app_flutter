import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/blocs/mentors/mentor_detail_bloc.dart';
import 'package:lms/blocs/mentors/mentors_event.dart';
import 'package:lms/cubits/admin/admin_user_cubit.dart';
import 'package:lms/models/role_model.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/widgets/custom_snackbar.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = '';
  String? _selectedRole;
  static const defaultAvatar = 'https://www.gravatar.com/avatar/?d=mp';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _justUpdatedRole = false;
  String? _lastUpdatedUserId;
  String? _lastUpdatedRole;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await context.read<AdminUserCubit>().getAllUsers();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return defaultAvatar;
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return avatarUrl;
    }
    return '${ApiConfig.baseUrl}$avatarUrl';
  }

  List<User> _filterUsers(List<User> users) {
    return users.where((user) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);

      final matchesRole = _selectedRole == null || user.role == _selectedRole;

      return matchesSearch && matchesRole;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value.toLowerCase());
  }

  void _showRoleUpdateDialog(User user) {
    final currentRole = Role.getRoleById(user.role);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(currentRole.icon, color: currentRole.color),
                const SizedBox(width: 12),
                const Text('Cập nhật vai trò'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn vai trò mới cho ${user.name}',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ...Role.availableRoles.map((role) {
                  final isSelected = role.id == currentRole.id;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: isSelected ? 2 : 0,
                    color: isSelected ? role.color.withOpacity(0.1) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? role.color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        if (isSelected) return;
                        Navigator.pop(context); // Đóng dialog trước
                        setState(() => _isLoading = true);
                        try {
                          await context.read<AdminUserCubit>().updateUserRole(
                            user.uid,
                            role.id,
                          );
                          _justUpdatedRole = true;
                          _lastUpdatedUserId = user.uid;
                          _lastUpdatedRole = role.id;
                          if (!mounted) return;
                          CustomSnackBar.showSuccess(
                            context: context,
                            message:
                                'Đã cập nhật vai trò cho ${user.name} thành ${role.name}',
                          );
                        } catch (e) {
                          if (!mounted) return;
                          CustomSnackBar.showError(
                            context: context,
                            message: 'Lỗi: ${e.toString()}',
                          );
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: role.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                role.icon,
                                color: role.color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? role.color : null,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    role.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          isSelected
                                              ? role.color.withOpacity(0.8)
                                              : theme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: role.color),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Hủy'),
              ),
            ],
          ),
    );
  }

  void _toggleUserStatus(User user) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              user.isActive ? 'Vô hiệu hóa người dùng' : 'Kích hoạt người dùng',
            ),
            content: Text(
              user.isActive
                  ? 'Bạn có chắc chắn muốn vô hiệu hóa tài khoản của ${user.name}?'
                  : 'Bạn có chắc chắn muốn kích hoạt tài khoản của ${user.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  if (!mounted) return;

                  setState(() => _isLoading = true);
                  try {
                    await context.read<AdminUserCubit>().toggleUserStatus(
                      user.uid,
                      status: user.isActive ? 'disabled' : 'active',
                    );

                    if (!mounted) return;
                    if (user.isActive) {
                      CustomSnackBar.showWarning(
                        context: context,
                        message: 'Đã vô hiệu hóa tài khoản của ${user.name}',
                      );
                    } else {
                      CustomSnackBar.showSuccess(
                        context: context,
                        message: 'Đã kích hoạt tài khoản của ${user.name}',
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Lỗi: ${e.toString()}',
                    );
                  } finally {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isActive ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
              ),
            ],
          ),
    );
  }

  void _showFilterBottomSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Lọc theo vai trò',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildRoleFilterButton(
                    icon: Icons.people,
                    label: 'Tất cả',
                    color: colorScheme.primary,
                    selected: _selectedRole == null,
                    onTap: () {
                      setState(() => _selectedRole = null);
                      Navigator.pop(context);
                    },
                  ),
                  ...Role.availableRoles.map(
                    (role) => _buildRoleFilterButton(
                      icon: role.icon,
                      label: role.name,
                      color: role.color,
                      selected: _selectedRole == role.id,
                      onTap: () {
                        setState(() => _selectedRole = role.id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              if (_selectedRole != null) ...[
                const SizedBox(height: 24),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _selectedRole = null);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.filter_alt_off),
                    label: const Text('Xóa bộ lọc'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleFilterButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quản lý người dùng',
        showSearch: true,
        onSearchChanged: _onSearchChanged,
        showMenu: true,
        showBack: true,
        menuItems: [
          const PopupMenuItem(
            value: 'filter',
            child: Row(
              children: [
                Icon(Icons.filter_list),
                SizedBox(width: 8),
                Text('Lọc theo vai trò'),
              ],
            ),
          ),
          if (_selectedRole != null)
            PopupMenuItem(
              value: 'clear_filter',
              child: Row(
                children: [
                  Icon(Icons.filter_alt_off, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Xóa bộ lọc',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'refresh',
            child: Row(
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 8),
                Text('Làm mới dữ liệu'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'help',
            child: Row(
              children: [
                Icon(Icons.help_outline),
                SizedBox(width: 8),
                Text('Trợ giúp'),
              ],
            ),
          ),
        ],
        onMenuSelected: (value) {
          switch (value) {
            case 'filter':
              _showFilterBottomSheet();
              break;
            case 'clear_filter':
              setState(() => _selectedRole = null);
              break;
            case 'refresh':
              _fetchUsers();
              break;
            case 'help':
              _showDebugInfo(context);
              break;
          }
        },
      ),
      body: BlocConsumer<AdminUserCubit, AdminUserState>(
        listener: (context, state) {
          if (state is AdminUserError) {
            CustomSnackBar.showError(context: context, message: state.message);
            _justUpdatedRole = false;
            _lastUpdatedUserId = null;
            _lastUpdatedRole = null;
          }
          if (state is AdminUserLoaded && _justUpdatedRole) {
            User? updatedUser;
            try {
              updatedUser = state.users.firstWhere(
                (u) => u.uid == _lastUpdatedUserId,
              );
            } catch (_) {
              updatedUser = null;
            }
            if (updatedUser != null && updatedUser.role == _lastUpdatedRole) {
              CustomSnackBar.showSuccess(
                context: context,
                message: 'Cập nhật vai trò thành công!',
              );
            }
            _justUpdatedRole = false;
            _lastUpdatedUserId = null;
            _lastUpdatedRole = null;
          }
        },
        builder: (context, state) {
          if (state is AdminUserLoading || _isLoading) {
            // Chỉ hiển thị loading indicator ở giữa
            return const Center(child: LoadingIndicator());
          }
          if (state is AdminUserError) {
            return _buildErrorState(state.message, colorScheme, theme);
          }
          if (state is AdminUserLoaded) {
            final filteredUsers = _filterUsers(state.users);
            if (filteredUsers.isEmpty) {
              return _buildEmptyState(theme);
            }
            return RefreshIndicator(
              onRefresh: _fetchUsers,
              child: _buildUserList(filteredUsers),
            );
          }
          return const Center(child: Text('Không có dữ liệu'));
        },
      ),
    );
  }

  Widget _buildUserList(List<User> users) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(context, user: user);
      },
    );
  }

  Widget _buildErrorState(
    String message,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Không thể tải dữ liệu',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            onPressed: _fetchUsers,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            isDark
                ? 'assets/images/empty_dark.png'
                : 'assets/images/empty_light.png',
            width: 120,
            height: 120,
            errorBuilder:
                (context, error, stackTrace) => Icon(
                  Icons.person_off,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedRole != null
                ? 'Không tìm thấy người dùng với vai trò ${Role.getRoleById(_selectedRole!).name}'
                : 'Không tìm thấy người dùng nào',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, {required User user}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bool isActive = user.isActive;
    final avatarUrl = _getAvatarUrl(user.avatarUrl);
    final role = Role.getRoleById(user.role);

    return InkWell(
      onTap: () => _navigateToUserDetail(user),
      borderRadius: BorderRadius.circular(20),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with border and status dot
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: role.color.withOpacity(0.5),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (user.bio.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.bio,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: isActive ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isActive ? 'Đang hoạt động' : 'Bị khóa',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _showRoleUpdateDialog(user),
                    icon: Icon(role.icon, size: 22),
                    color: role.color,
                    tooltip: 'Thay đổi vai trò',
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () => _toggleUserStatus(user),
                    icon: Icon(
                      isActive ? Icons.lock : Icons.lock_open,
                      size: 22,
                    ),
                    color: isActive ? Colors.red : Colors.green,
                    tooltip: isActive ? 'Vô hiệu hóa' : 'Kích hoạt',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUserDetail(User user) {
    context.read<MentorDetailBloc>().add(GetMentorByUidEvent(user.uid));
    Navigator.pushNamed(
      context,
      AppRouter.adminUserDetail,
      arguments: user.uid,
    );
  }

  void _showDebugInfo(BuildContext context) {
    final state = context.read<AdminUserCubit>().state;
    String stateInfo = 'Current State: ${state.runtimeType}';

    if (state is AdminUserLoaded) {
      stateInfo += '\nLoaded ${state.users.length} users';

      final roleCount = <String, int>{};
      final activeCount = state.users.where((u) => u.isActive).length;

      for (final user in state.users) {
        final role = user.role.toLowerCase();
        roleCount[role] = (roleCount[role] ?? 0) + 1;
      }

      stateInfo += '\n\nThống kê:';
      stateInfo += '\nTổng số: ${state.users.length}';
      stateInfo += '\nĐang hoạt động: $activeCount';
      stateInfo += '\nBị khóa: ${state.users.length - activeCount}';

      roleCount.forEach((role, count) {
        stateInfo += '\n$role: $count';
      });
    } else if (state is AdminUserError) {
      stateInfo += '\nError: ${state.message}';
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thông tin trợ giúp'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(stateInfo),
                  const Divider(),
                  const Text(
                    'API Endpoints:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('GET /api/users - Lấy danh sách người dùng'),
                  const Text(
                    'PUT /api/users/:uid/status - Thay đổi trạng thái',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _fetchUsers();
                },
                child: const Text('Làm mới'),
              ),
            ],
          ),
    );
  }
}
