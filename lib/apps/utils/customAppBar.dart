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

  /// Hiển thị elevation
  final bool showElevation;

  /// Hiển thị bottom border
  final bool showBottomBorder;

  /// Custom actions
  final List<Widget>? actions;

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
    this.showElevation = false,
    this.showBottomBorder = true,
    this.actions,
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

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  final _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _animationController.forward();
      } else {
        _animationController.reverse();
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
      elevation: widget.showElevation ? 1 : 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      centerTitle: widget.centerTitle,
      titleSpacing: 0,
      toolbarHeight: 64,

      // back button
      leading:
          widget.showBack
              ? Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                  onPressed: widget.onBack ?? () => Navigator.maybePop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
              : null,

      // title hoặc search field
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child:
            _isSearching
                ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? theme.colorScheme.surface
                                : theme.colorScheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
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
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                              size: 20,
                            ),
                            onPressed: _toggleSearch,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.transparent,
                            ),
                          ),
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
      ),

      // actions: search + menu-icon(always) + optional popup
      actions: [
        // Custom actions
        if (widget.actions != null) ...widget.actions!,

        // search toggle
        if (widget.showSearch && !_isSearching)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.onSurface,
                size: 22,
              ),
              onPressed: _toggleSearch,
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        // icon 3-chấm luôn hiện nếu showMenu = true
        if (widget.showMenu)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child:
                widget.menuItems != null
                    ? PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: theme.colorScheme.onSurface,
                        size: 22,
                      ),
                      onSelected: widget.onMenuSelected,
                      itemBuilder: (_) => widget.menuItems!,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      position: PopupMenuPosition.under,
                    )
                    : IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: theme.colorScheme.onSurface,
                        size: 22,
                      ),
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
          ),
      ],

      // TabBar hoặc bottom border
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          (widget.tabs != null && widget.tabs!.isNotEmpty)
              ? kTextTabBarHeight
              : widget.showBottomBorder
              ? 1
              : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.tabs != null && widget.tabs!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TabBar(
                  tabs: widget.tabs!,
                  labelStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: theme.textTheme.titleMedium,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                    0.6,
                  ),
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              )
            else if (widget.showBottomBorder)
              Container(
                height: 1,
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
          ],
        ),
      ),
    );
  }
}
