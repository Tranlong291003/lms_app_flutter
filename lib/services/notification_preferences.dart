import 'package:shared_preferences/shared_preferences.dart';

/// Lưu tuỳ chọn nhận thông báo của người dùng xuống máy.
///
/// Trước đây màn hình "Thông báo" vẽ 3 công tắc nhưng `onChanged` chỉ hiện
/// snackbar "Chức năng đang được phát triển": gạt công tắc không có tác dụng
/// gì, và vì giá trị được truyền cứng (`isEnabled: true/false`) nên mở lại
/// màn hình là trạng thái quay về như cũ.
class NotificationPreferences {
  static const _keyCourse = 'notify_course';
  static const _keyMessage = 'notify_message';
  static const _keyPromotion = 'notify_promotion';

  /// Giá trị mặc định khi người dùng chưa từng thay đổi.
  static const bool defaultCourse = true;
  static const bool defaultMessage = true;
  static const bool defaultPromotion = false;

  static Future<bool> getCourse() async =>
      (await SharedPreferences.getInstance()).getBool(_keyCourse) ??
      defaultCourse;

  static Future<bool> getMessage() async =>
      (await SharedPreferences.getInstance()).getBool(_keyMessage) ??
      defaultMessage;

  static Future<bool> getPromotion() async =>
      (await SharedPreferences.getInstance()).getBool(_keyPromotion) ??
      defaultPromotion;

  static Future<void> setCourse(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_keyCourse, value);

  static Future<void> setMessage(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_keyMessage, value);

  static Future<void> setPromotion(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_keyPromotion, value);
}
