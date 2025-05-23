import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/mentor_request_cubit.dart';
import 'package:lms/widgets/custom_snackbar.dart';

class MentorRequestAdminScreen extends StatefulWidget {
  const MentorRequestAdminScreen({super.key});

  @override
  State<MentorRequestAdminScreen> createState() =>
      _MentorRequestAdminScreenState();
}

class _MentorRequestAdminScreenState extends State<MentorRequestAdminScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MentorRequestCubit>().fetchAllUpgradeRequests();
  }

  void _handleApprove(int id) async {
    await context.read<MentorRequestCubit>().updateUpgradeRequestStatus(
      id: id,
      status: 'approved',
      reason: null,
    );
    CustomSnackBar.showSuccess(context: context, message: 'Duyệt thành công!');
    context.read<MentorRequestCubit>().fetchAllUpgradeRequests();
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
      await context.read<MentorRequestCubit>().updateUpgradeRequestStatus(
        id: id,
        status: 'rejected',
        reason: reason.trim(),
      );
      CustomSnackBar.showSuccess(
        context: context,
        message: 'Từ chối thành công!',
      );
      context.read<MentorRequestCubit>().fetchAllUpgradeRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyệt yêu cầu Mentor'),
        centerTitle: true,
        elevation: 1,
      ),
      body: BlocBuilder<MentorRequestCubit, MentorRequestState>(
        builder: (context, state) {
          if (state is MentorRequestLoading) {
            return const Center(child: LoadingIndicator());
          }
          if (state is MentorRequestError) {
            return Center(
              child: Text(
                'Lỗi: ${state.message}',
                style: textTheme.titleMedium?.copyWith(
                  color: c.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          if (state is MentorRequestListLoaded) {
            final requests = state.requests;
            if (requests.isEmpty) {
              return Center(
                child: Text(
                  'Không có yêu cầu nào.',
                  style: textTheme.titleMedium?.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final req = requests[i];
                final name =
                    (req['user_name'] ?? req['user_uid'] ?? 'Không rõ')
                        .toString();
                final status = (req['status'] ?? '').toString();
                final statusColor =
                    status == 'approved'
                        ? Colors.green.shade600
                        : status == 'rejected'
                        ? Colors.red.shade600
                        : Colors.orange.shade700;
                final statusLabel =
                    status == 'approved'
                        ? 'Đã duyệt'
                        : status == 'rejected'
                        ? 'Đã từ chối'
                        : 'Chờ duyệt';

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: statusColor.withOpacity(0.4),
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
                              Chip(
                                label: Text(
                                  statusLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: statusColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                              ),
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
                                  color: Colors.green.shade700,
                                  size: 28,
                                ),
                                tooltip: 'Duyệt',
                                onPressed: () => _handleApprove(req['id']),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.cancel_rounded,
                                  color: Colors.red.shade700,
                                  size: 28,
                                ),
                                tooltip: 'Từ chối',
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
