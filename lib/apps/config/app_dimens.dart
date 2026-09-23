import 'package:flutter/widgets.dart';

/// Thang kích thước dùng chung cho toàn app.
///
/// Vì sao cần file này: trước đây mỗi màn hình tự chọn số. Thống kê trên
/// `lib/` cho thấy 15 giá trị bo góc khác nhau (`circular(2)` … `circular(50)`)
/// và hơn 12 giá trị lề (`EdgeInsets.all(3)` … `EdgeInsets.all(32)`) cho cùng
/// một loại khối. Hệ quả là hai màn hình cùng chức năng nhưng bo góc lệch nhau
/// vài px, nhìn ra ngay là "không cùng một app".
///
/// Quy ước: mọi khoảng cách là bội của 4. Khi cần một giá trị mới, chọn token
/// gần nhất thay vì viết số trực tiếp.
abstract final class AppSpacing {
  /// 4 — khe hở nhỏ nhất giữa icon và nhãn.
  static const double xs = 4;

  /// 8 — khe hở giữa các phần tử liền kề trong một khối.
  static const double sm = 8;

  /// 12 — khe hở giữa các dòng trong cùng một nhóm.
  static const double md = 12;

  /// 16 — lề chuẩn của màn hình và khoảng cách giữa các khối.
  static const double lg = 16;

  /// 20 — lề trong của thẻ lớn.
  static const double xl = 20;

  /// 24 — khoảng cách giữa các nhóm nội dung.
  static const double xxl = 24;

  /// 32 — khoảng cách giữa các vùng lớn của màn hình.
  static const double xxxl = 32;
}

/// Bán kính bo góc dùng chung.
///
/// Rút gọn danh sách cũ về 5 bậc có ý nghĩa:
///  - [sm]  : chip, badge, ô nhập nhỏ
///  - [md]  : nút, ô nhập liệu, thẻ danh sách  (mặc định)
///  - [lg]  : thẻ nội dung, hộp thoại
///  - [xl]  : khối lớn, ảnh bìa, banner
///  - [pill]: viên thuốc (bo tròn hoàn toàn)
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Bo tròn hoàn toàn — dùng cho chip/avatar/nút dạng viên.
  static const double pill = 999;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderPill = BorderRadius.all(
    Radius.circular(pill),
  );
}

/// Kích thước cố định dùng nhiều nơi.
abstract final class AppSizes {
  /// Chiều cao tối thiểu của một vùng chạm theo chuẩn Material.
  static const double minTapTarget = 48;

  /// Chiều cao chuẩn của nút hành động chính.
  static const double buttonHeight = 50;

  /// Chiều cao thanh công cụ (khớp `CustomAppBar.toolbarHeight`).
  static const double appBarHeight = 64;

  /// Cạnh của avatar nhỏ trong danh sách.
  static const double avatarSm = 40;

  /// Cạnh của avatar lớn ở trang hồ sơ.
  static const double avatarLg = 96;

  /// Tỉ lệ ảnh bìa/thumbnail khoá học (16:9).
  static const double thumbnailAspectRatio = 16 / 9;
}
