// lib/apps/utils/json_parse.dart

/// Các helper đọc dữ liệu JSON an toàn về kiểu.
///
/// PostgreSQL trả `BIGINT`/`NUMERIC`/`COUNT()` dưới dạng **chuỗi** trong JSON
/// (ví dụ `"enroll_count": "3"`), trong khi các cột `INT` trả về số thật. Vì vậy
/// không được ép kiểu trực tiếp bằng `as int` — sẽ ném lỗi khi giá trị là chuỗi
/// hoặc null. Dùng các hàm dưới đây cho mọi trường số đọc từ API.
library;

int asInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

int? asIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

double asDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? fallback;
  return fallback;
}

double? asDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

bool asBool(dynamic value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0' || normalized.isEmpty) {
      return false;
    }
  }
  return fallback;
}

String asString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

String? asStringOrNull(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

/// `options` của câu hỏi có thể là mảng thật hoặc chuỗi JSON đã serialize.
List<String> asStringList(dynamic value) {
  if (value == null) return const [];
  if (value is List) {
    return value.map((e) => e?.toString() ?? '').toList();
  }
  return const [];
}

DateTime? asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

DateTime asDateTimeOr(dynamic value, DateTime fallback) =>
    asDateTime(value) ?? fallback;
