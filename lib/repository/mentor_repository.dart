import 'package:lms/models/user_model.dart';
import 'package:lms/services/mentor_service.dart';

class MentorRepository {
  final MentorService _service;
  MentorRepository(this._service);

  Future<List<User>> getAllMentors({String? search}) async {
    final rawList = await _service.fetchAllMentors(search: search);

    final users = rawList.map((json) => User.fromJson(json)).toList();

    print('objects: users');
    return users;
  }
}
