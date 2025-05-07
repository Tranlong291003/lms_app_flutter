import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Hiện nút back (nếu true)
  final bool showBack;
  final VoidCallback? onBack;

  /// Tiêu đề
  final String? title;
  final bool centerTitle;

  /// Bật search
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;

  /// Hiển thị icon 3-chấm
  final bool showMenu;

  /// Nếu != null thì nhấn icon sẽ bật popup menu
  final List<PopupMenuEntry<String>>? menuItems;
  final ValueChanged<String>? onMenuSelected;

  /// TabBar nếu cần
  final List<Tab>? tabs;

  const CustomAppBar({
    super.key,
    this.showBack = false,
    this.onBack,
    this.title,
    this.centerTitle = false,
    this.showSearch = false,
    this.onSearchChanged,
    this.showMenu = false,
    this.menuItems,
    this.onMenuSelected,
    this.tabs,
  });

  @override
  Size get preferredSize {
    final base = kToolbarHeight;
    final extra = (tabs != null && tabs!.isNotEmpty) ? kTextTabBarHeight : 0;
    return Size.fromHeight(base + extra);
  }

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isSearching = false;
  final _controller = TextEditingController();

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _controller.clear();
        widget.onSearchChanged?.call('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      centerTitle: widget.centerTitle,
      titleSpacing: 0,

      // back button
      leading:
          widget.showBack
              ? Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 22,
                  ),
                  onPressed: widget.onBack ?? () => Navigator.maybePop(context),
                ),
              )
              : null,

      // title hoặc search field
      title:
          _isSearching
              ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? theme.colorScheme.surface
                            : theme.colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: widget.onSearchChanged,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: _toggleSearch,
                      ),
                    ),
                  ),
                ),
              )
              : Padding(
                padding: EdgeInsets.only(left: widget.showBack ? 8.0 : 24.0),
                child: Text(
                  widget.title ?? '',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),

      // actions: search + menu-icon(always) + optional popup
      actions: [
        // search toggle
        if (widget.showSearch && !_isSearching)
          IconButton(
            padding: const EdgeInsets.only(right: 12.0),
            icon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _toggleSearch,
          ),

        // icon 3-chấm luôn hiện nếu showMenu = true
        if (widget.showMenu)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child:
                widget.menuItems != null
                    // có menuItems → hiển thị PopupMenuButton
                    ? PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      onSelected: widget.onMenuSelected,
                      itemBuilder: (_) => widget.menuItems!,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    )
                    // không có menuItems → chỉ hiển thị icon, không popup
                    : IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      onPressed: () {},
                    ),
          ),
      ],

      // TabBar nếu có
      bottom:
          (widget.tabs != null && widget.tabs!.isNotEmpty)
              ? PreferredSize(
                preferredSize: const Size.fromHeight(kTextTabBarHeight),
                child: Container(
                  color: theme.scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TabBar(
                    tabs: widget.tabs!,
                    labelStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: theme.textTheme.titleMedium,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface
                        .withOpacity(0.6),
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                  ),
                ),
              )
              : null,
    );
  }
}
