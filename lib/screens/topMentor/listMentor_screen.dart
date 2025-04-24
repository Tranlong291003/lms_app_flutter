import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';

class ListMentorScreen extends StatelessWidget {
  ListMentorScreen({super.key});

  final List<Map<String, String>> mentors = [
    {
      'name': 'Nguyễn Văn Minh',
      'description': 'Chuyên viên phân tích thị trường',
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Trần Thị Mai',
      'description': 'Phó giám đốc kinh doanh',
      'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'name': 'Lê Hồng Ánh',
      'description': 'Nhà thiết kế trải nghiệm người dùng',
      'avatar': 'https://randomuser.me/api/portraits/women/3.jpg',
    },
    {
      'name': 'Phạm Quốc Huy',
      'description': 'Trưởng bộ phận kỹ thuật giải pháp',
      'avatar': 'https://randomuser.me/api/portraits/men/4.jpg',
    },
    {
      'name': 'Vũ Thị Bích Ngọc',
      'description': 'Quản lý sản phẩm',
      'avatar': 'https://randomuser.me/api/portraits/women/5.jpg',
    },
    {
      'name': 'Đỗ Thanh Tùng',
      'description': 'Giảng viên công nghệ thông tin',
      'avatar': 'https://randomuser.me/api/portraits/men/6.jpg',
    },
    {
      'name': 'Ngô Thị Thanh',
      'description': 'Giảng viên kinh tế',
      'avatar': 'https://randomuser.me/api/portraits/women/7.jpg',
    },
    {
      'name': 'Bùi Quang Dũng',
      'description': 'Chuyên gia trí tuệ nhân tạo',
      'avatar': 'https://randomuser.me/api/portraits/men/8.jpg',
    },
    {
      'name': 'Trịnh Thị Hạnh',
      'description': 'Cố vấn học thuật',
      'avatar': 'https://randomuser.me/api/portraits/women/9.jpg',
    },
    {
      'name': 'Hoàng Văn Sơn',
      'description': 'Giáo viên lập trình di động',
      'avatar': 'https://randomuser.me/api/portraits/men/10.jpg',
    },
    {
      'name': 'Phan Thị Kim Ngân',
      'description': 'Quản lý đào tạo',
      'avatar': 'https://randomuser.me/api/portraits/women/11.jpg',
    },
    {
      'name': 'Mai Anh Dũng',
      'description': 'Giảng viên AI',
      'avatar': 'https://randomuser.me/api/portraits/men/12.jpg',
    },
    {
      'name': 'Nguyễn Thị Hoa',
      'description': 'Giảng viên tâm lý học',
      'avatar': 'https://randomuser.me/api/portraits/women/13.jpg',
    },
    {
      'name': 'Lê Quốc Thịnh',
      'description': 'Kỹ sư phần mềm cao cấp',
      'avatar': 'https://randomuser.me/api/portraits/men/14.jpg',
    },
    {
      'name': 'Đặng Thị Cẩm Tú',
      'description': 'Giảng viên quản trị kinh doanh',
      'avatar': 'https://randomuser.me/api/portraits/women/15.jpg',
    },
    {
      'name': 'Phùng Minh Hòa',
      'description': 'Nhà nghiên cứu giáo dục',
      'avatar': 'https://randomuser.me/api/portraits/men/16.jpg',
    },
    {
      'name': 'Tạ Thị Yến Nhi',
      'description': 'Giảng viên thiết kế đồ hoạ',
      'avatar': 'https://randomuser.me/api/portraits/women/17.jpg',
    },
    {
      'name': 'Võ Đức Trí',
      'description': 'Trưởng phòng công nghệ',
      'avatar': 'https://randomuser.me/api/portraits/men/18.jpg',
    },
    {
      'name': 'Lý Như Quỳnh',
      'description': 'Chuyên viên tư vấn hướng nghiệp',
      'avatar': 'https://randomuser.me/api/portraits/women/19.jpg',
    },
    {
      'name': 'Nguyễn Tuấn Kiệt',
      'description': 'Giảng viên lập trình web',
      'avatar': 'https://randomuser.me/api/portraits/men/20.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDarkMode ? colorScheme.surface : Colors.grey[50],
      appBar: CustomAppBar(
        showBack: true,
        showSearch: true,
        title: 'Danh sách giảng viên',
        onSearchChanged: (value) {
          // Gọi API tìm kiếm ở đây
          // Có thể debounce bằng Bloc hoặc timer
          print('Đang tìm kiếm: $value');
        },
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: mentors.length,
        itemBuilder: (context, index) {
          final mentor = mentors[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // Handle mentor selection
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Hero(
                      tag: 'mentor-${mentor['name']}',
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            mentor['avatar']!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.person),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mentor['name']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mentor['description']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: colorScheme.primary,
                      ),
                      onPressed: () {
                        // Mở hộp thoại trò chuyện
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
