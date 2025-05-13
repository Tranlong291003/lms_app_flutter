import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Model cho một slide khuyến mãi
class Promotion {
  final String discountText;
  final String headline;
  final String subhead;
  final String description;
  final List<Color> colors;
  final IconData icon;
  final String buttonText;

  Promotion({
    required this.discountText,
    required this.headline,
    required this.subhead,
    required this.description,
    required this.colors,
    required this.icon,
    required this.buttonText,
  });
}

class DiscountSlider extends StatefulWidget {
  const DiscountSlider({super.key});

  @override
  _DiscountSliderState createState() => _DiscountSliderState();
}

class _DiscountSliderState extends State<DiscountSlider>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  final List<Promotion> _promotions = [
    Promotion(
      discountText: '30%',
      headline: 'Giới thiệu bạn',
      subhead: 'Cả đôi cùng giảm',
      description: 'Mời bạn bè, cả hai nhận ngay 30% cho mọi khóa học.',
      colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
      icon: Icons.people_alt,
      buttonText: 'Giới thiệu ngay',
    ),
    Promotion(
      discountText: '50%',
      headline: 'Tuần lễ vàng',
      subhead: 'Ưu đãi nửa giá',
      description:
          'Giảm ngay 50% tất cả khóa học lập trình web & mobile trong tuần này!',
      colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
      icon: Icons.laptop_mac,
      buttonText: 'Đăng ký ngay',
    ),
    Promotion(
      discountText: 'Combo',
      headline: 'Học nhiều, Tiết kiệm nhiều',
      subhead: 'Tiết kiệm đến 45%',
      description:
          'Đăng ký combo 3 khóa học chỉ với giá của 2 khóa. Thời gian có hạn!',
      colors: [Color(0xFF614385), Color(0xFF516395)],
      icon: Icons.library_books,
      buttonText: 'Xem combo',
    ),
    Promotion(
      discountText: 'Miễn phí',
      headline: 'Khóa học AI cơ bản',
      subhead: 'Số lượng có hạn',
      description:
          'Trải nghiệm khóa học AI cơ bản hoàn toàn miễn phí. Số slot giới hạn!',
      colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      icon: Icons.psychology,
      buttonText: 'Nhận ngay',
    ),
    Promotion(
      discountText: 'Pro',
      headline: 'Premium',
      subhead: 'Học không giới hạn',
      description: '199 k/tháng truy cập toàn bộ khóa học.',
      colors: [Color(0xFFED213A), Color(0xFF93291E)],
      icon: Icons.workspace_premium,
      buttonText: 'Nâng cấp ngay',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final promo = _promotions[_currentPage];

    return Column(
      children: [
        Container(
          height: 140,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Stack(
            children: [
              // Phần nền gradient với hình ảnh
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: promo.colors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),

              // Page view
              PageView.builder(
                controller: _pageController,
                itemCount: _promotions.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final p = _promotions[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Hiệu ứng trang trí bên trong
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -15,
                          left: -15,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),

                        // Hiệu ứng hoa văn trang trí
                        Positioned.fill(
                          child: CustomPaint(
                            painter: PatternPainter(
                              color: Colors.white.withOpacity(0.03),
                            ),
                          ),
                        ),

                        // Nội dung
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Phần biểu tượng minh họa (đặt bên trái)
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle:
                                        index == _currentPage
                                            ? _rotateAnimation.value
                                            : 0.0,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                  child: Icon(
                                    p.icon,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Phần văn bản (ở giữa)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        // Phần tiêu đề
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            p.discountText,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          p.subhead,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.headline,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.description,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.8),
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Nút CTA (bên phải)
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTapDown:
                                    (_) => _animationController.forward(),
                                onTapUp: (_) => _animationController.reverse(),
                                onTapCancel:
                                    () => _animationController.reverse(),
                                onTap: () {
                                  // Xử lý khi nhấn vào nút
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã chọn: ${p.headline}'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: AnimatedBuilder(
                                  animation: _animationController,
                                  builder:
                                      (context, child) => Transform.scale(
                                        scale:
                                            index == _currentPage
                                                ? _scaleAnimation.value
                                                : 1.0,
                                        child: child,
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      p.buttonText,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: p.colors[1],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Chỉ báo trang ở giữa dưới cùng
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _promotions.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 6,
                      dotWidth: 6,
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withOpacity(0.4),
                      spacing: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Vẽ họa tiết trang trí cho nền
class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final double spacing = 15;

    // Vẽ các đường chéo song song
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
