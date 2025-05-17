import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/blocs/mentors/mentor_detail_bloc.dart';
import 'package:lms/blocs/mentors/mentors_event.dart';
import 'package:lms/cubits/admin/admin_user_cubit.dart';
import 'package:lms/models/role_model.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/screens/user_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = '';
  static const defaultAvatar = 'https://www.gravatar.com/avatar/?d=mp';

  final TextEditingController _searchController = TextEditingController();

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

  void _fetchUsers() {
    context.read<AdminUserCubit>().getAllUsers();
  }

  String _getAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return defaultAvatar;
    }
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return avatarUrl;
    }
    return '${ApiConfig.baseUrl}$avatarUrl';
  }

  List<User> _filterUsers(List<User> users) {
    return users.where((user) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.role.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesSearch;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
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
                      onTap: () {
                        // if (!isSelected) {
                        //   context.read<AdminUserCubit>().updateUserRole(
                        //     user.uid,
                        //     role.id,
                        //   );
                        //   Navigator.pop(context);
                        // }
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminUserLoading) {
            return _buildLoadingList();
          }
          if (state is AdminUserError) {
            return _buildErrorState(state.message, colorScheme, theme);
          }
          if (state is AdminUserLoaded) {
            final filteredUsers = _filterUsers(state.users);
            if (filteredUsers.isEmpty) {
              return _buildEmptyState(theme);
            }
            return _buildUserList(filteredUsers);
          }
          return const Center(child: Text('Không có dữ liệu'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchUsers,
        tooltip: 'Làm mới dữ liệu',
        child: const Icon(Icons.refresh),
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

  Widget _buildLoadingList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder:
          (context, index) => Shimmer.fromColors(
            baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            highlightColor:
                isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 120,
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 150,
                            height: 15,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 100,
                            height: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            'Không tìm thấy người dùng nào',
            style: theme.textTheme.titleLarge,
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

    return Card(
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
                      border: Border.all(color: colorScheme.surface, width: 2),
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
                  icon: Icon(isActive ? Icons.lock : Icons.lock_open, size: 22),
                  color: isActive ? Colors.red : Colors.green,
                  tooltip: isActive ? 'Vô hiệu hóa' : 'Kích hoạt',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleUserStatus(User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AdminUserCubit>().toggleUserStatus(user.uid);
                  Navigator.pop(context);
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

  void _navigateToUserDetail(User user) {
    context.read<MentorDetailBloc>().add(GetMentorByUidEvent(user.uid));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailScreen(uid: user.uid)),
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
