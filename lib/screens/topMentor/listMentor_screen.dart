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
    return Scaffold(
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
        itemCount: mentors.length,
        itemBuilder: (context, index) {
          final mentor = mentors[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(mentor['avatar']!),
            ),
            title: Text(
              mentor['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(mentor['description']!),
            trailing: IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
              onPressed: () {
                // Mở hộp thoại trò chuyện
              },
            ),
          );
        },
      ),
    );
  }
}
