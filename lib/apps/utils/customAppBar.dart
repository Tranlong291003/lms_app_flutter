import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showSearch = true,
    this.onSearchChanged,
    this.onBack,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isSearching = false;
  final TextEditingController _controller = TextEditingController();

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        _controller.clear();
        widget.onSearchChanged?.call('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: widget.onBack ?? () => Navigator.pop(context),
      ),
      title:
          isSearching
              ? TextField(
                controller: _controller,
                autofocus: true,
                onChanged: widget.onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm...',
                  border: InputBorder.none,
                ),
              )
              : Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      actions:
          widget.showSearch
              ? [
                IconButton(
                  icon: Icon(isSearching ? Icons.close : Icons.search),
                  onPressed: _toggleSearch,
                ),
              ]
              : null,
    );
  }
}
