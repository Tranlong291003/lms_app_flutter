import 'package:lms/models/user_model.dart';
import 'package:lms/services/user_service.dart';

class UserRepository {
  final UserService _userService;

  UserRepository(this._userService);

  // Lấy thông tin người dùng
  Future<User> getUserByUid(String uid) async {
    try {
      return await _userService.getUserByUid(uid);
    } catch (e) {
      throw Exception('Không thể lấy thông tin người dùng từ kho dữ liệu: $e');
    }
  }

  // Cập nhật hồ sơ người dùng
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? avatarUrl,
    String? bio,
    String? phone,
  }) async {
    try {
      await _userService.updateUserProfile(
        uid: uid,
        name: name,
        avatarUrl: avatarUrl,
        bio: bio,
        phone: phone,
      );
    } catch (e) {
      throw Exception('Không thể cập nhật hồ sơ người dùng: $e');
    }
  }
}
