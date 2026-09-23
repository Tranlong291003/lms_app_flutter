import 'package:flutter/material.dart';

import 'package:lms/apps/config/app_dimens.dart';

/// Ô tìm kiếm dùng chung.
///
/// Trước đây widget này có tham số `onFilter` nhưng **không hề vẽ nút lọc**, nên
/// hai màn hình quản lý khoá học truyền `onFilter: () => _showFilterDialog(...)`
/// mà bộ lọc không bao giờ mở được — tính năng đã viết xong nhưng vô hình.
/// Nút lọc giờ được vẽ khi `onFilter != null`.
class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  /// Nếu != null thì hiện nút lọc ở cuối ô tìm kiếm.
  final VoidCallback? onFilter;

  final String? hintText;
  final bool autofocus;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry? margin;
  final ValueChanged<String>? onSubmitted;

  const SearchBarWidget({
    super.key,
    this.onChanged,
    this.onFilter,
    this.hintText,
    this.autofocus = false,
    this.controller,
    this.onClear,
    this.margin,
    this.onSubmitted,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);

    if (_controller.text.isNotEmpty) {
      _showClearButton = true;
    }
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClearButton) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      // Chiều cao tối thiểu thay vì cố định 52px: ở cỡ chữ hệ thống lớn, chữ
      // trong ô cần nhiều chỗ hơn và `height` cứng sẽ cắt mất.
      constraints: const BoxConstraints(minHeight: 52),
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderLg,
        color:
            isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              autofocus: widget.autofocus,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              cursorColor: colorScheme.primary,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                hintText: widget.hintText ?? 'Tìm kiếm khoá học, chủ đề...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                  horizontal: AppSpacing.sm,
                ),
                isDense: true,
                suffixIcon:
                    _showClearButton
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: _clearSearch,
                            tooltip: 'Xoá tìm kiếm',
                          )
                        : null,
              ),
            ),
          ),
          // Nút lọc — chỉ hiện khi nơi gọi thực sự truyền `onFilter`.
          if (widget.onFilter != null) ...[
            Container(
              width: 1,
              height: 28,
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            IconButton(
              icon: Icon(Icons.tune_rounded, color: colorScheme.primary),
              onPressed: widget.onFilter,
              tooltip: 'Bộ lọc',
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
