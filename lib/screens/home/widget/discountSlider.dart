import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Model cho một slide khuyến mãi
class Promotion {
  final String discountText;
  final String headline;
  final String subhead;
  final String description;
  final List<Color> colors;

  Promotion({
    required this.discountText,
    required this.headline,
    required this.subhead,
    required this.description,
    required this.colors,
  });
}

class DiscountSlider extends StatefulWidget {
  const DiscountSlider({super.key});

  @override
  _DiscountSliderState createState() => _DiscountSliderState();
}

class _DiscountSliderState extends State<DiscountSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Promotion> _promotions = [
    Promotion(
      discountText: '15%',
      headline: 'Ưu đãi lần đầu',
      subhead: 'Cho học viên mới',
      description: 'Giảm 15% khi mua khoá học đầu tiên trên app!',
      colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    ),
    Promotion(
      discountText: '25%',
      headline: 'Combo chuyên sâu',
      subhead: 'Full‑stack & AI',
      description: 'Tiết kiệm 25% khi mua trọn bộ 2 khoá học Full‑stack & AI.',
      colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
    ),
    Promotion(
      discountText: 'Free',
      headline: '7 ngày dùng thử',
      subhead: 'Truy cập Premium',
      description:
          'Thoả sức học không giới hạn 7 ngày với tài khoản Premium miễn phí.',
      colors: [Color(0xFFCC2B5E), Color(0xFF753A88)],
    ),
    Promotion(
      discountText: '20%',
      headline: 'Giới thiệu bạn bè',
      subhead: 'Nhận thưởng kép',
      description:
          'Bạn và bạn bè cùng được 20% off khi đăng ký qua link giới thiệu.',
      colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
    ),
    Promotion(
      discountText: '30%',
      headline: 'Flash Sale Nhanh',
      subhead: 'Chỉ hôm nay',
      description: 'Giảm ngay 30% cho 100 đơn đầu tiên!',
      colors: [Color(0xFFFFB439), Color(0xFFFFCE00)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
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
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: promo.colors,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _promotions.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final p = _promotions[index];
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${p.discountText} OFF',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
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
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    p.discountText,
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
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
                padding: const EdgeInsets.only(bottom: 10),
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
        ),
      ],
    );
  }
}
