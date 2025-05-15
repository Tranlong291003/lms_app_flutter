import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Model slide khuyến mãi
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
  State<DiscountSlider> createState() => _DiscountSliderState();
}

class _DiscountSliderState extends State<DiscountSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Danh sách khuyến mãi (giữ nguyên từ code đầu tiên)
  final List<Promotion> _promotions = [
    Promotion(
      discountText: '30%',
      headline: 'Giới thiệu bạn',
      subhead: 'Cả đôi cùng giảm',
      description: 'Mời bạn bè, cả hai nhận ngay 30% cho mọi khóa học.',
      colors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      icon: Icons.people_alt,
      buttonText: 'Giới thiệu ngay',
    ),
    Promotion(
      discountText: '50%',
      headline: 'Tuần lễ vàng',
      subhead: 'Ưu đãi nửa giá',
      description:
          'Giảm ngay 50% tất cả khóa học lập trình web & mobile trong tuần này!',
      colors: [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)],
      icon: Icons.laptop_mac,
      buttonText: 'Đăng ký ngay',
    ),
    Promotion(
      discountText: 'Combo',
      headline: 'Học nhiều, Tiết kiệm nhiều',
      subhead: 'Tiết kiệm đến 45%',
      description:
          'Đăng ký combo 3 khóa học chỉ với giá của 2 khóa. Thời gian có hạn!',
      colors: [const Color(0xFF614385), const Color(0xFF516395)],
      icon: Icons.library_books,
      buttonText: 'Xem combo',
    ),
    Promotion(
      discountText: 'Miễn phí',
      headline: 'Khóa học AI cơ bản',
      subhead: 'Số lượng có hạn',
      description:
          'Trải nghiệm khóa học AI cơ bản hoàn toàn miễn phí. Số slot giới hạn!',
      colors: [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
      icon: Icons.psychology,
      buttonText: 'Nhận ngay',
    ),
    Promotion(
      discountText: 'Pro',
      headline: 'Premium',
      subhead: 'Học không giới hạn',
      description: '199 k/tháng truy cập toàn bộ khóa học.',
      colors: [const Color(0xFFED213A), const Color(0xFF93291E)],
      icon: Icons.workspace_premium,
      buttonText: 'Nâng cấp ngay',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page!.round());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promo = _promotions[_currentPage];

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          height: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              clipBehavior: Clip.hardEdge, // cắt gọn tất cả hoạ tiết
              children: [
                // Nền gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: promo.colors,
                      ),
                    ),
                  ),
                ),
                // Vòng tròn mờ trang trí
                Positioned(top: -20, right: -20, child: _decorCircle(100)),
                Positioned(bottom: -15, left: -15, child: _decorCircle(60)),
                // Pattern chéo
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _PatternPainter(
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                ),

                // Nội dung PageView & indicator
                Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _promotions.length,
                        itemBuilder: (context, index) {
                          final p = _promotions[index];
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    // Icon
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.18),
                                      ),
                                      child: Icon(
                                        p.icon,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Văn bản
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.headline,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            p.subhead,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      p.discountText,
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  p.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _promotions.length,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Vòng tròn mờ trang trí
  Widget _decorCircle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.10),
    ),
  );
}

/// Vẽ pattern chéo trang trí
class _PatternPainter extends CustomPainter {
  final Color color;
  const _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    const spacing = 15.0;
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
