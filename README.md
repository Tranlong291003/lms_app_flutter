# LMS App (Flutter)

Ứng dụng học trực tuyến (Learning Management System) xây dựng bằng Flutter, hoạt động dựa trên REST API backend (mặc định chạy ở cổng `3000`).

Ứng dụng hỗ trợ 3 nhóm vai trò: **Học viên**, **Mentor** (giảng viên) và **Admin**.

## Tính năng chính

### Học viên
- Đăng ký / đăng nhập (Firebase Auth + JWT), quên mật khẩu, đổi mật khẩu
- Trang chủ: khóa học nổi bật, danh mục, mentor hàng đầu
- Khóa học: xem chi tiết, danh sách bài giảng (video YouTube), đăng ký học
- Khóa học của tôi: đang học / đã hoàn thành, theo dõi tiến độ
- Quiz: làm bài có tính giờ, xem kết quả và lịch sử làm bài
- Mentor: xem danh sách, chi tiết mentor, gửi yêu cầu trở thành mentor
- Bookmark khóa học, thông báo (push FCM + local notification)
- Hồ sơ cá nhân: chỉnh sửa thông tin, avatar
- Cài đặt: dark/light mode, ngôn ngữ, bảo mật, quyền riêng tư, trợ giúp, mời bạn bè, thanh toán

### Mentor
- Dashboard mentor
- Quản lý khóa học (tạo, sửa, xóa), quản lý bài giảng
- Tạo quiz và câu hỏi (thủ công hoặc sinh bằng AI)

### Admin
- Dashboard thống kê ứng dụng (số người dùng, khóa học, ...)
- Quản lý người dùng (khóa/mở khóa tài khoản), quản lý khóa học, quản lý danh mục
- Duyệt yêu cầu mentor

## Kiến trúc

Dự án theo mô hình phân lớp, luồng dữ liệu một chiều:

```
Screen (UI)  →  Bloc/Cubit (state)  →  Repository  →  Service (Dio)  →  REST API
```

- **State management**: `flutter_bloc` (BLoC cho theme/user/mentor, Cubit cho auth và các feature còn lại)
- **Dependency injection**: `provider` (MultiProvider / RepositoryProvider / BlocProvider) khai báo tập trung tại `lib/main.dart`
- **Routing**: `AppRouter.generateRoute` — named routes kèm hiệu ứng chuyển trang
- **Xác thực**: JWT token lưu trong `SharedPreferences`, tự động gắn header `Authorization: Bearer` qua Dio interceptor; nhận `401` sẽ tự động đăng xuất

### Cấu trúc thư mục

```
lib/
├── apps/
│   ├── config/        # api_config, app_router, app_theme, app_dimens
│   └── utils/         # widget dùng chung (button, app bar, dialog, ...)
├── blocs/             # BLoC: mentors, theme, user
├── cubits/            # Cubit: admin, bookmark, category, courses, lessons, quiz, ...
├── models/            # Data models (course, lesson, quiz, user, ...)
├── repositories/      # Lớp trung gian giữa state và service
├── screens/           # UI theo từng feature (home, course_detail, quiz, dashboard, ...)
└── services/          # Gọi API qua Dio, kế thừa BaseService
```

## Hệ thống thiết kế

Mọi màu sắc và kích thước lấy từ **một** nguồn, không viết số trực tiếp trong
màn hình:

| Cần gì | Dùng gì |
|---|---|
| Màu theo vai trò Material (nền, chữ, viền…) | `Theme.of(context).colorScheme.*` |
| Màu trạng thái (thành công / cảnh báo / lỗi / thông tin) | `AppColors.of(context).success` … — tự đổi theo sáng/tối |
| Khoảng cách | `AppSpacing.xs/sm/md/lg/xl/xxl/xxxl` (bội của 4) |
| Bo góc | `AppRadius.sm/md/lg/xl/xxl/pill` |
| Kích thước cố định | `AppSizes.minTapTarget/buttonHeight/appBarHeight` |

Widget dùng chung cho các khối lặp lại nhiều nơi:

- `CourseCard` — thẻ khoá học (trang chủ, tìm kiếm, đã lưu)
- `EmptyStateWidget` — trạng thái rỗng/lỗi, kèm `listPaddingWithBottomInset`
- `StatusChip` — nhãn trạng thái (có cả chấm màu **và** chữ)
- `StatGrid` — lưới số liệu trên dashboard
- `CustomSnackBar`, `CustomDialog`, `CustomAppBar`, `LoadingIndicator`

### Test bảo vệ giao diện

```bash
flutter test test/design_consistency_test.dart   # tương phản màu, token
flutter test test/screen_layout_audit_test.dart  # 17 màn hình × 3 kích thước × 2 chế độ
flutter test test/stat_grid_layout_test.dart     # lưới số liệu ở cỡ chữ lớn
flutter test test/layout_responsive_test.dart    # thẻ khoá học, trạng thái rỗng
```

`design_consistency_test.dart` kiểm tra bằng số (công thức tương phản WCAG) nên
không phụ thuộc vào việc nhìn ảnh chụp: nếu ai đó đổi một màu làm chữ khó đọc,
test đổ ngay.

## Công nghệ sử dụng

| Nhóm | Packages |
|---|---|
| State management | `flutter_bloc`, `provider`, `equatable` |
| Networking | `dio` |
| Firebase / thông báo | `firebase_core`, `firebase_auth`, `firebase_messaging`, `flutter_local_notifications` |
| Lưu trữ cục bộ | `shared_preferences` |
| UI / Media | `cached_network_image`, `shimmer`, `flutter_slidable`, `google_fonts`, `page_transition`, `smooth_page_indicator`, `animated_text_kit`, `introduction_screen`, `loading_animation_widget` |
| Video | `youtube_player_flutter` |
| Tiện ích | `image_picker`, `file_picker`, `permission_handler`, `url_launcher`, `intl`, `flutter_datetime_picker_plus` |

Yêu cầu môi trường: Flutter SDK 3.7.2+ (Dart `^3.7.2`). Ứng dụng hiện chỉ hỗ trợ **Android**.

## Bắt đầu

### Yêu cầu
- Flutter SDK 3.7.2 trở lên
- Android SDK / thiết bị hoặc emulator Android
- Backend LMS API đang chạy (mặc định `http://<host>:3000`)

### Cài đặt

1. Cài dependencies:
   ```bash
   flutter pub get
   ```

2. Cấu hình địa chỉ API trong `lib/apps/config/api_config.dart`:
   ```dart
   static const String baseUrl = "http://192.168.10.203:3000";
   ```
   Lưu ý: khi chạy trên máy thật hoặc emulator, dùng IP LAN của máy chạy backend, không dùng `localhost`.

3. Cấu hình Firebase: file `android/app/google-services.json` đã có trong repo, cần đảm bảo đúng project Firebase đang dùng.

4. Chạy ứng dụng:
   ```bash
   flutter run
   ```

### Build

```bash
# APK release
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release
```

### Kiểm tra chất lượng code

```bash
flutter analyze
```

## Quyền hệ thống

Ứng dụng yêu cầu các quyền: thông báo (Android 13+), đọc/ghi bộ nhớ ngoài (dùng cho tải/chọn file). Quyền được xin ngay khi khởi động app trong `lib/main.dart`.

## Ghi chú

- Entry point: `lib/main.dart` — khởi tạo Firebase, đăng ký toàn bộ Service / Repository / Bloc-Cubit vào widget tree.
- Màn hình đầu tiên là `AppEntryGate`, tự điều hướng dựa trên trạng thái đăng nhập và trạng thái xem màn hình giới thiệu (intro).
- Xử lý `401 Unauthorized` tập trung tại `lib/services/base_service.dart`: xóa token và đưa người dùng về màn hình đăng nhập.
