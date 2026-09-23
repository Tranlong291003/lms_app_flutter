import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/status_chip.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/mentor_request_cubit.dart';

class MentorRequestAdminScreen extends StatefulWidget {
  const MentorRequestAdminScreen({super.key});

  @override
  State<MentorRequestAdminScreen> createState() =>
      _MentorRequestAdminScreenState();
}

class _MentorRequestAdminScreenState extends State<MentorRequestAdminScreen> {
  /// Tu khoa loc (o tim kiem tren AppBar).
  ///
  /// Truoc day `onSearchChanged` chi la `// TODO` nen go vao khong loc gi:
  /// nguoi dung go ma danh sach khong doi, tuong tim kiem bi loi.
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<MentorRequestCubit>().fetchAllUpgradeRequests();
  }

  void _handleApprove(int id) async {
    // `updateUpgradeRequestStatus` tự `catch` lỗi và emit `MentorRequestError`,
    // KHÔNG ném ra ngoài — nên `await` luôn hoàn tất bình thường. Trước đây chỉ
    // cần vậy là báo "Duyệt thành công!", kể cả khi server lỗi: admin tưởng đã
    // duyệt trong khi yêu cầu vẫn "Chờ duyệt". Phải kiểm tra trạng thái thật.
    final cubit = context.read<MentorRequestCubit>();
    await cubit.updateUpgradeRequestStatus(
      id: id,
      status: 'approved',
      reason: null,
    );
    if (!mounted) return;

    if (cubit.state is MentorRequestError) {
      CustomSnackBar.showError(
        context: context,
        message: 'Duyệt thất bại. Vui lòng thử lại.',
      );
      return;
    }

    CustomSnackBar.showSuccess(context: context, message: 'Duyệt thành công!');
    cubit.fetchAllUpgradeRequests();
  }

  void _handleReject(int id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String? inputReason;
        return AlertDialog(
          title: const Text('Nhập lý do từ chối'),
          content: TextField(
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Nhập lý do...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: (v) => inputReason = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (inputReason == null || inputReason!.trim().isEmpty) return;
                Navigator.pop(ctx, inputReason);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
    if (reason != null && reason.trim().isNotEmpty) {
      final cubit = context.read<MentorRequestCubit>();
      await cubit.updateUpgradeRequestStatus(
        id: id,
        status: 'rejected',
        reason: reason.trim(),
      );
      if (!mounted) return;

      // Cùng lý do như `_handleApprove`: cubit nuốt lỗi nên phải tự kiểm tra.
      if (cubit.state is MentorRequestError) {
        CustomSnackBar.showError(
          context: context,
          message: 'Từ chối thất bại. Vui lòng thử lại.',
        );
        return;
      }

      CustomSnackBar.showSuccess(
        context: context,
        message: 'Từ chối thành công!',
      );
      cubit.fetchAllUpgradeRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Duyệt yêu cầu Mentor',
        showBack: true,
        showSearch: true,
        onSearchChanged: (value) {
          setState(() => _searchQuery = value.trim().toLowerCase());
        },
      ),
      body: BlocBuilder<MentorRequestCubit, MentorRequestState>(
        builder: (context, state) {
          if (state is MentorRequestLoading) {
            return const Center(child: LoadingIndicator());
          }
          if (state is MentorRequestError) {
            return EmptyStateWidget(
              icon: Icons.cloud_off_rounded,
              title: 'Không tải được danh sách yêu cầu',
              message: state.message,
              isError: true,
              actionLabel: 'Thử lại',
              onAction: () =>
                  context.read<MentorRequestCubit>().fetchAllUpgradeRequests(),
            );
          }
          if (state is MentorRequestListLoaded) {
            final all = state.requests;

            if (all.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.inbox_outlined,
                title: 'Chưa có yêu cầu nào',
                message: 'Yêu cầu đăng ký mentor mới sẽ xuất hiện ở đây.',
              );
            }

            // Loc theo ten/uid nguoi gui (o tim kiem tren AppBar).
            final requests =
                _searchQuery.isEmpty
                    ? all
                    : all.where((r) {
                      final name =
                          (r['user_name'] ?? r['user_uid'] ?? '').toString();
                      return name.toLowerCase().contains(_searchQuery);
                    }).toList();

            if (requests.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'Không tìm thấy yêu cầu',
                message: 'Không có yêu cầu nào khớp với "$_searchQuery".',
              );
            }

            return ListView.separated(
              padding: listPaddingWithBottomInset(context),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final req = requests[i];
                final name =
                    (req['user_name'] ?? req['user_uid'] ?? 'Không rõ')
                        .toString();
                final status = (req['status'] ?? '').toString();
                // `StatusChip` tự lo màu theo sáng/tối và phân biệt trạng thái
                // bằng cả chấm màu lẫn chữ — trước đây chip dùng
                // `Colors.green/red/orange` với chữ trắng (2.2–2.9:1) nên gần
                // như không đọc được.
                final tone = StatusChip.toneFor(status);
                final statusLabel = switch (status) {
                  'approved' => 'Đã duyệt',
                  'rejected' => 'Đã từ chối',
                  _ => 'Chờ duyệt',
                };

                return Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              req['image_url'] != null
                                  ? Image.network(
                                    req['image_url'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          width: 60,
                                          height: 60,
                                          color: c.surfaceContainerHighest,
                                          child: const Icon(
                                            Icons.image_not_supported_rounded,
                                            size: 32,
                                          ),
                                        ),
                                  )
                                  : Container(
                                    width: 60,
                                    height: 60,
                                    color: c.surfaceContainerHighest,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 32,
                                    ),
                                  ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              StatusChip(label: statusLabel, tone: tone),
                            ],
                          ),
                        ),
                        if (status == 'pending')
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.of(context).success,
                                  size: 28,
                                ),
                                tooltip: 'Duyệt yêu cầu',
                                onPressed: () => _handleApprove(req['id']),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.cancel_rounded,
                                  color: AppColors.of(context).error,
                                  size: 28,
                                ),
                                tooltip: 'Từ chối yêu cầu',
                                onPressed: () => _handleReject(req['id']),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
