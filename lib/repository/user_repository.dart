import 'package:lms/models/user_model.dart';
import 'package:lms/services/user_service.dart';

class UserRepository {
  final UserService _userService;

  UserRepository(this._userService);

  Future<User> getUserByUid(String uid) async {
    try {
      return await _userService.getUserByUid(uid);
    } catch (e) {
      throw Exception('Failed to get user from repository: $e');
    }
  }
}
