import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Detail',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: const CourseDetailScreen(),
    );
  }
}

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildBody(context)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: _enrollButton(),
      ),
    );
  }

  /* ---------------- SliverAppBar ---------------- */
  SliverAppBar _buildAppBar(BuildContext context) => SliverAppBar(
    pinned: true,
    expandedHeight: 200,
    leading: BackButton(
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
    ),
    flexibleSpace: const FlexibleSpaceBar(
      background: Image(
        image: NetworkImage(
          'https://vtiacademy.edu.vn/upload/images/cau-lac-bo/thiet-ke-ui-ux-la-gi-tai-sao-nghe-ux-ui-ngay-cang-hot.jpg',
        ),
        fit: BoxFit.cover,
      ),
    ),
  );

  /* ---------------- Main body ---------------- */
  Widget _buildBody(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleSection(),
        const SizedBox(height: 16),
        _statsSection(),
        const SizedBox(height: 24),
        _tabSection(context),
        // nút _enrollButton() đã được chuyển xuống bottomNavigationBar
      ],
    ),
  );

  /* ---------------- Title & Bookmark ---------------- */
  Widget _titleSection() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          'Giới thiệu về thiết kế UI/UX',
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      const Icon(Icons.bookmark_border, color: Colors.grey),
    ],
  );

  /* ---------------- Quick stats ---------------- */
  Widget _statsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _chip('Thiết kế UI/UX'),
          const SizedBox(width: 8),
          _starRating(),
        ],
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: const [
          _IconText(icon: Icons.people, text: '9.839 học viên'),
          _IconText(icon: Icons.timer, text: '2.5 giờ học'),
          _IconText(icon: Icons.verified, text: 'Có chứng chỉ'),
        ],
      ),
    ],
  );

  Widget _chip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color:
          Theme.of(context).brightness == Brightness.light
              ? Colors.blue[50]
              : Colors.blue[900],
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: const TextStyle(fontSize: 12)),
  );

  Widget _starRating() => Row(
    children: const [
      Icon(Icons.star, size: 18, color: Colors.amber),
      SizedBox(width: 4),
      Text('4.8 (4.479 đánh giá)'),
    ],
  );

  /* ---------------- Tabs ---------------- */
  Widget _tabSection(BuildContext context) => DefaultTabController(
    length: 3,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TabBar(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(text: 'Giới thiệu'),
            Tab(text: 'Bài học'),
            Tab(text: 'Đánh giá'),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: const TabBarView(
            children: [
              _AboutTab(),
              Center(child: Text('Danh sách bài học sẽ ở đây.')),
              Center(child: Text('Đánh giá từ học viên.')),
            ],
          ),
        ),
      ],
    ),
  );

  /* ---------------- Enroll Button (full-width) ---------------- */
  Widget _enrollButton() => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: () {
        // TODO: Xử lý đăng ký
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text(
        'Đăng ký khoá học miễn phí',
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}

/* ========================================================================= */
/* ---------------- Helper Widgets ---------------- */
class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: Colors.grey),
      const SizedBox(width: 4),
      Text(text),
    ],
  );
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Giảng viên',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/images/mentor.png'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Jonathan Williams',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Chuyên gia thiết kế tại Google'),
                ],
              ),
              const Spacer(),
              Icon(Icons.chat_bubble_outline, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Giới thiệu khoá học',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _ExpandableDescription(),
          const SizedBox(height: 24),
          const Text(
            'Công cụ sử dụng',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.network(
                'https://blog.greggant.com/images/posts/2019-04-25-figma/Figma.png',
                width: 20,
              ),
              const SizedBox(width: 8),
              const Text('Figma'),
            ],
          ),
        ],
      ),
    ),
  );
}

/* ---------------- Expandable description ---------------- */
class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription();

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;
  final String _text =
      'Khoá học này sẽ cung cấp cho bạn kiến thức cơ bản đến nâng cao về thiết kế giao diện người dùng và trải nghiệm người dùng. '
      'Bạn sẽ học cách tạo ra các giao diện đẹp mắt, dễ sử dụng và tối ưu cho người dùng.';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _expanded || _text.length <= 120
            ? _text
            : '${_text.substring(0, 120)}...',
        textAlign: TextAlign.justify,
        style: const TextStyle(fontSize: 14),
      ),
      if (_text.length > 120)
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Thu gọn' : 'Xem thêm...',
            style: TextStyle(color: Colors.blue[600]),
          ),
        ),
    ],
  );
}
