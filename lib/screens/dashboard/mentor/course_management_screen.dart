import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'course_detail/course_detail_screen.dart';
import 'course_form_screen.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  // ===== Mock data demo (sẽ thay bằng API sau) =====
  final List<Map<String, dynamic>> courses = [
    {
      'id': 1,
      'title': 'Khóa học Flutter nâng cao',
      'description':
          'Học lập trình Flutter từ cơ bản đến nâng cao với nhiều ví dụ thực tế. Khóa học này sẽ giúp bạn nắm vững các kiến thức về Flutter framework, Dart programming và xây dựng ứng dụng di động trên nhiều nền tảng.',
      'thumbnail_url': 'https://picsum.photos/800/600?random=1',
      'enrollment_count': 120,
      'lessons': 12,
      'rating': 4.8,
      'status': true,
      'category_id': 2,
      'category_name': 'Lập trình Mobile...tttttttttttttttttttt..j',
      'level': 'Cơ bản',
      'price': 200000,
      'discount_price': 150000,
      'language': 'Tiếng Việt',
      'tags': 'flutter, mobile, dart, widget, material design',
      'total_video_duration': '10:30:45',
      'created_at': '2023-05-15',
      'updated_at': '2023-10-22',
      'instructor_name': 'Nguyễn Văn Giảng Viên',
      'instructor_bio':
          'Chuyên gia Flutter với 5+ năm kinh nghiệm phát triển ứng dụng di động đa nền tảng. Đã xuất bản nhiều ứng dụng với hàng triệu lượt tải.',
      'lessonsList': [
        {
          'id': 101,
          'title': 'Giới thiệu Flutter và cài đặt môi trường',
          'description':
              'Tổng quan về Flutter framework và hướng dẫn cài đặt môi trường phát triển trên Windows, macOS và Linux.',
          'duration': '45:20',
          'video_url': 'https://example.com/videos/flutter-intro',
        },
        {
          'id': 102,
          'title': 'Ngôn ngữ Dart cơ bản',
          'description':
              'Học về cú pháp, biến, hàm, lớp và các khái niệm cơ bản trong Dart programming language.',
          'duration': '1:15:30',
          'video_url': 'https://example.com/videos/dart-basics',
        },
        {
          'id': 103,
          'title': 'Stateless và Stateful Widgets',
          'description':
              'Tìm hiểu về sự khác biệt giữa Stateless và Stateful widgets và khi nào nên sử dụng chúng.',
          'duration': '55:15',
          'video_url': 'https://example.com/videos/flutter-widgets',
        },
        {
          'id': 104,
          'title': 'Quản lý state với Provider',
          'description':
              'Học cách quản lý state hiệu quả trong Flutter sử dụng thư viện Provider.',
          'duration': '1:10:00',
          'video_url': 'https://example.com/videos/flutter-provider',
        },
        {
          'id': 105,
          'title': 'Làm việc với API và JSON',
          'description':
              'Kết nối với REST API và xử lý dữ liệu JSON trong Flutter.',
          'duration': '1:25:10',
          'video_url': 'https://example.com/videos/flutter-api',
        },
      ],
      'quizList': [
        {
          'id': 201,
          'title': 'Kiểm tra kiến thức cơ bản',
          'type': 'Trắc nghiệm',
          'time_limit': 20,
          'passing_score': 70,
          'questions': [
            {
              'id': 301,
              'question': 'Flutter được phát triển bởi công ty nào?',
              'answer': 'Google',
              'options': ['Apple', 'Google', 'Microsoft', 'Facebook'],
            },
            {
              'id': 302,
              'question': 'Ngôn ngữ lập trình nào được sử dụng trong Flutter?',
              'answer': 'Dart',
              'options': ['Java', 'Swift', 'Dart', 'Kotlin'],
            },
            {
              'id': 303,
              'question': 'Thành phần cơ bản nhất trong Flutter UI là gì?',
              'answer': 'Widget',
              'options': ['Component', 'Element', 'Widget', 'View'],
            },
            {
              'id': 304,
              'question': 'Hot Reload trong Flutter có tác dụng gì?',
              'answer':
                  'Cập nhật UI ngay lập tức không mất trạng thái ứng dụng',
              'options': [
                'Khởi động lại ứng dụng',
                'Cập nhật UI ngay lập tức không mất trạng thái ứng dụng',
                'Tối ưu hiệu năng ứng dụng',
                'Xóa bộ nhớ cache',
              ],
            },
          ],
        },
        {
          'id': 202,
          'title': 'Kiểm tra kiến thức nâng cao',
          'type': 'Tự luận',
          'time_limit': 30,
          'passing_score': 75,
          'questions': [
            {
              'id': 305,
              'question':
                  'Giải thích sự khác biệt giữa StatelessWidget và StatefulWidget?',
              'answer':
                  'StatelessWidget không thay đổi trạng thái trong quá trình chạy, còn StatefulWidget có thể thay đổi trạng thái khi người dùng tương tác.',
            },
            {
              'id': 306,
              'question': 'Tại sao Flutter sử dụng widget tree thay vì DOM?',
              'answer':
                  'Flutter sử dụng widget tree để tăng hiệu năng render UI, giảm việc phụ thuộc vào các DOM của nền tảng gốc, cho phép đồng nhất UI trên các nền tảng khác nhau.',
            },
            {
              'id': 307,
              'question': 'Giải thích cách Provider hoạt động trong Flutter?',
              'answer':
                  'Provider là một giải pháp quản lý state, hoạt động dựa trên InheritedWidget của Flutter, cung cấp khả năng truyền dữ liệu xuống widget tree mà không cần truyền qua tham số constructor, giúp ứng dụng dễ bảo trì hơn.',
            },
          ],
        },
      ],
    },
    {
      'id': 2,
      'title': 'Khóa học React Native',
      'description':
          'Lập trình di động đa nền tảng với React Native. Học cách tạo ứng dụng iOS và Android từ một codebase JavaScript.',
      'thumbnail_url': 'https://picsum.photos/800/600?random=2',
      'enrollment_count': 80,
      'lessons': 10,
      'rating': 4.5,
      'status': false,
      'category_id': 2,
      'category_name': 'Lập trình Mobile',
      'level': 'Trung bình',
      'price': 180000,
      'discount_price': 0,
      'language': 'Tiếng Việt',
      'tags': 'react, mobile, javascript, nodejs, redux',
      'total_video_duration': '08:45:30',
      'created_at': '2023-03-10',
      'updated_at': '2023-09-15',
      'instructor_name': 'Trần Thị Hướng Dẫn',
      'instructor_bio':
          'Frontend Developer với 7 năm kinh nghiệm, chuyên về React và React Native. Đã giảng dạy cho hơn 2000 học viên.',
      'lessonsList': [
        {
          'id': 106,
          'title': 'Giới thiệu React Native',
          'description': 'Tổng quan về React Native và cách nó hoạt động.',
          'duration': '40:15',
          'video_url': 'https://example.com/videos/react-native-intro',
        },
        {
          'id': 107,
          'title': 'Cài đặt môi trường phát triển',
          'description':
              'Hướng dẫn cài đặt các công cụ cần thiết cho phát triển React Native.',
          'duration': '55:30',
          'video_url': 'https://example.com/videos/react-native-setup',
        },
        {
          'id': 108,
          'title': 'Components cơ bản',
          'description':
              'Tìm hiểu các components cơ bản trong React Native như View, Text, Image.',
          'duration': '1:05:20',
          'video_url': 'https://example.com/videos/react-native-components',
        },
        {
          'id': 109,
          'title': 'Navigation và Routing',
          'description':
              'Học cách xây dựng navigation flow trong ứng dụng React Native.',
          'duration': '1:15:00',
          'video_url': 'https://example.com/videos/react-native-navigation',
        },
      ],
      'quizList': [
        {
          'id': 203,
          'title': 'Kiểm tra React Native cơ bản',
          'type': 'Trắc nghiệm',
          'time_limit': 15,
          'passing_score': 60,
          'questions': [
            {
              'id': 308,
              'question': 'React Native được phát triển bởi công ty nào?',
              'answer': 'Facebook',
              'options': ['Google', 'Microsoft', 'Facebook', 'Amazon'],
            },
            {
              'id': 309,
              'question':
                  'Ngôn ngữ lập trình nào được sử dụng chính trong React Native?',
              'answer': 'JavaScript',
              'options': ['Swift', 'Java', 'Kotlin', 'JavaScript'],
            },
            {
              'id': 310,
              'question':
                  'Đâu KHÔNG phải là component có sẵn của React Native?',
              'answer': 'Route',
              'options': ['View', 'Text', 'Route', 'Image'],
            },
          ],
        },
      ],
    },
    {
      'id': 3,
      'title': 'Machine Learning và AI với Python',
      'description':
          'Học về trí tuệ nhân tạo, học máy và deep learning từ cơ bản đến nâng cao với Python và các thư viện phổ biến.',
      'thumbnail_url': 'https://picsum.photos/800/600?random=3',
      'enrollment_count': 150,
      'lessons': 15,
      'rating': 4.9,
      'status': true,
      'category_id': 3,
      'category_name': 'Khoa học Dữ liệu',
      'level': 'Nâng cao',
      'price': 300000,
      'discount_price': 250000,
      'language': 'Tiếng Việt',
      'tags': 'machine learning, python, AI, tensorflow, keras, deep learning',
      'total_video_duration': '15:20:30',
      'created_at': '2023-01-20',
      'updated_at': '2023-11-05',
      'instructor_name': 'TS. Lê Văn Khoa Học',
      'instructor_bio':
          'Tiến sĩ AI tại Đại học Stanford, có 10 năm kinh nghiệm trong lĩnh vực trí tuệ nhân tạo và học máy.',
      'lessonsList': [
        {
          'id': 110,
          'title': 'Nhập môn Machine Learning',
          'description':
              'Giới thiệu về Machine Learning và các ứng dụng trong thực tế.',
          'duration': '50:30',
          'video_url': 'https://example.com/videos/ml-intro',
        },
        {
          'id': 111,
          'title': 'Python cho Machine Learning',
          'description':
              'Các thư viện Python cơ bản phục vụ cho machine learning: NumPy, Pandas, Matplotlib.',
          'duration': '1:30:15',
          'video_url': 'https://example.com/videos/python-ml',
        },
        {
          'id': 112,
          'title': 'Thuật toán học có giám sát',
          'description':
              'Hồi quy tuyến tính, phân loại logistic và cây quyết định.',
          'duration': '2:15:00',
          'video_url': 'https://example.com/videos/supervised-learning',
        },
        {
          'id': 113,
          'title': 'Mạng neural và Deep Learning',
          'description':
              'Cơ bản về mạng neural và xây dựng mô hình deep learning với TensorFlow và Keras.',
          'duration': '3:00:45',
          'video_url': 'https://example.com/videos/deep-learning',
        },
      ],
      'quizList': [
        {
          'id': 204,
          'title': 'Quiz Machine Learning cơ bản',
          'type': 'Trắc nghiệm',
          'time_limit': 30,
          'passing_score': 80,
          'questions': [
            {
              'id': 311,
              'question':
                  'Thuật toán nào sau đây KHÔNG phải là học có giám sát?',
              'answer': 'K-means',
              'options': [
                'Linear Regression',
                'Decision Trees',
                'K-means',
                'Logistic Regression',
              ],
            },
            {
              'id': 312,
              'question':
                  'Thư viện nào sau đây không phổ biến trong machine learning với Python?',
              'answer': 'jQuery',
              'options': ['TensorFlow', 'PyTorch', 'Scikit-learn', 'jQuery'],
            },
            {
              'id': 313,
              'question':
                  'Đâu là bước quan trọng trong quy trình machine learning?',
              'answer': 'Tiền xử lý dữ liệu',
              'options': [
                'Cài đặt IDE',
                'Tiền xử lý dữ liệu',
                'Thay đổi giao diện',
                'Tối ưu hóa URL',
              ],
            },
            {
              'id': 314,
              'question':
                  'Thuật ngữ "epoch" trong deep learning có nghĩa là gì?',
              'answer': 'Một lần duyệt qua toàn bộ tập dữ liệu huấn luyện',
              'options': [
                'Một lần duyệt qua toàn bộ tập dữ liệu huấn luyện',
                'Số lượng layer trong mạng neural',
                'Thời gian huấn luyện mô hình',
                'Số lượng tham số trong mô hình',
              ],
            },
          ],
        },
        {
          'id': 205,
          'title': 'Deep Learning nâng cao',
          'type': 'Tự luận',
          'time_limit': 45,
          'passing_score': 70,
          'questions': [
            {
              'id': 315,
              'question':
                  'Giải thích sự khác biệt giữa CNN và RNN và các ứng dụng thực tế của chúng?',
              'answer':
                  'CNN (Convolutional Neural Network) chuyên dụng cho dữ liệu không gian như hình ảnh, tận dụng tính chất cục bộ thông qua các lớp tích chập. RNN (Recurrent Neural Network) phù hợp với dữ liệu chuỗi như văn bản, âm thanh nhờ khả năng lưu trữ thông tin từ các bước trước.',
            },
            {
              'id': 316,
              'question':
                  'Giải thích vấn đề "vanishing gradient" trong deep learning và cách khắc phục?',
              'answer':
                  'Vanishing gradient là hiện tượng gradient trở nên rất nhỏ khi lan truyền ngược qua nhiều layer, khiến các layer đầu khó huấn luyện. Cách khắc phục: sử dụng hàm kích hoạt ReLU, kiến trúc skip connection như trong ResNet, batch normalization, và kiến trúc LSTM/GRU cho mạng RNN.',
            },
          ],
        },
      ],
    },
  ];

  // ============== Navigation helpers ==============
  Future<void> _addCourse() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CourseFormScreen(isEdit: false)),
    );
    if (result != null) setState(() => courses.add(result));
  }

  Future<void> _editCourse(int index) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => CourseFormScreen(isEdit: true, initialData: courses[index]),
      ),
    );
    if (result != null) setState(() => courses[index] = result);
  }

  Future<void> _deleteCourse(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận xoá'),
            content: Text(
              'Bạn chắc chắn muốn xoá " ${courses[index]['title']} " ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Huỷ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xoá', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (ok ?? false) setState(() => courses.removeAt(index));
  }

  // ============== UI ==============
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý khóa học'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addCourse),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, index) {
          final c = courses[index];
          return Slidable(
            key: ValueKey(c['title']),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                // Nút sửa
                SlidableAction(
                  onPressed: (_) => _editCourse(index),
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  icon: Icons.edit_outlined,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.all(8),
                  spacing: 0,
                ),

                // Nút xóa
                SlidableAction(
                  onPressed: (_) => _deleteCourse(index),
                  backgroundColor: colors.error,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline_rounded,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.all(8),
                  spacing: 0,
                ),
              ],
            ),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(18),
              color: colors.surface,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(course: c),
                      ),
                    ),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 120),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -------- THUMB --------
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: c['thumbnail_url'] ?? '',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder:
                              (_, __) => Container(
                                width: 90,
                                height: 90,
                                color: colors.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image,
                                  size: 30,
                                  color: colors.onSurfaceVariant.withOpacity(
                                    0.5,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (_, __, ___) => Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 32,
                                      color: colors.primary.withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No Image',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // -------- INFO --------
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              c['title'],
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Price
                            _PriceTag(
                              price: c['price'],
                              discount: c['discount_price'],
                              bgColor: colors.primary,
                            ),
                            const SizedBox(height: 6),
                            // Desc
                            SizedBox(
                              height: 36, // Đảm bảo luôn 2 dòng
                              child: Text(
                                c['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Stats row
                            Row(
                              children: [
                                _IconStat(
                                  icon: Icons.people,
                                  text: '${c['enrollment_count']} HV',
                                ),
                                _IconStat(
                                  icon: Icons.menu_book,
                                  text: '${c['lessons']} bài',
                                ),
                                _IconStat(
                                  icon: Icons.star,
                                  text: c['rating'].toString(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // -------- Status dot --------
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: c['status'] ? Colors.green : colors.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/*============= Widgets con =============*/
class _PriceTag extends StatelessWidget {
  final int? price;
  final int? discount;
  final Color bgColor;
  const _PriceTag({this.price, this.discount, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    String txt;
    if (discount != null && discount! > 0 && discount != price) {
      txt = '${_fmt(discount!)}đ';
    } else if (price == null || price == 0) {
      txt = 'Miễn phí';
    } else {
      txt = '${_fmt(price!)}đ';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        txt,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => '.',
  );
}

class _IconStat extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconStat({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 3),
          Text(text, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
