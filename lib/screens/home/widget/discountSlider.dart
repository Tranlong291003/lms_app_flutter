import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Thêm import này

class DiscountSlider extends StatefulWidget {
  const DiscountSlider({super.key});

  @override
  State<DiscountSlider> createState() => _DiscountSliderState();
}

class _DiscountSliderState extends State<DiscountSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180, // Chiều cao của container
          margin: const EdgeInsets.only(left: 6, right: 6, top: 10, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade400,
                Colors.pink.shade400,
              ], // Dải màu gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ), // Thêm gradient background
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Đổ bóng cho slider
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
                  itemCount: 4, // Số lượng slide là 4
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(12), // Giảm padding để vừa
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Phần bên trái
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // % OFF nhỏ
                                        Text(
                                          '${(index + 1) * 10}% Giảm giá',
                                          style: const TextStyle(
                                            fontSize:
                                                16, // Giảm cỡ chữ cho % OFF
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ), // Khoảng cách nhỏ
                                        // "Today's Special"
                                        Text(
                                          "Ưu đãi đặc biệt hôm nay",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Phần bên phải
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // % lớn
                                        Text(
                                          '${(index + 1) * 10}%',
                                          style: const TextStyle(
                                            fontSize: 48, // Giảm kích thước chữ
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Mô tả
                              Text(
                                'Nhận giảm giá cho mỗi đơn hàng khóa học!\nChỉ áp dụng hôm nay!',
                                style: const TextStyle(
                                  fontSize: 14, // Giảm kích thước chữ
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center, // Căn giữa mô tả
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10, // Điều chỉnh khoảng cách dưới
                ),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 4, // Số lượng trang
                  effect: WormEffect(
                    dotHeight: 8, // Giảm kích thước chấm
                    dotWidth: 8, // Giảm kích thước chấm
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
