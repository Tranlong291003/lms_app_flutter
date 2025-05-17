import 'package:lms/models/user_model.dart';
import 'package:lms/repositories/base_repository.dart';
import 'package:lms/services/mentor_service.dart';

class MentorRepository extends BaseRepository<MentorService> {
  MentorRepository(super.service);

  Future<List<User>> getAllMentors({String? search}) async {
    final rawList = await service.fetchAllMentors(search: search);
    final users = rawList.map((json) => User.fromJson(json)).toList();
    print('objects: users');
    return users;
  }

  Future<User> getMentorByUid(String uid) async {
    try {
      return await service.getMentorByUid(uid);
    } catch (e) {
      throw Exception('Không thể lấy thông tin người dùng: $e');
    }
  }
}
