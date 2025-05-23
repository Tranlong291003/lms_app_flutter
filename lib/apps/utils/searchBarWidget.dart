import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String>? onChanged;
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

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  bool _showClearButton = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_controller.text.isNotEmpty) {
      _showClearButton = true;
      _animationController.value = 1.0;
    }
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClearButton) {
      setState(() {
        _showClearButton = hasText;
      });
      if (hasText) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 52,
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color:
            isDark
                ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
                : colorScheme.surface,
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        border: Border.all(
          color:
              isDark
                  ? colorScheme.outline.withOpacity(0.2)
                  : colorScheme.outline.withOpacity(0.1),
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
                fontSize: 16,
              ),
              cursorColor: colorScheme.primary,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary.withOpacity(0.8),
                  size: 24,
                ),
                hintText: widget.hintText ?? 'Tìm kiếm khoá học, chủ đề...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
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
                          splashRadius: 20,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Xóa tìm kiếm',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        )
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
