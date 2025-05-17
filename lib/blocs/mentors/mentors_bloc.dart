import 'package:bloc/bloc.dart';
import 'package:lms/blocs/mentors/mentors_event.dart';
import 'package:lms/blocs/mentors/mentors_state.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/repositories/mentor_repository.dart';

class MentorsBloc extends Bloc<MentorsEvent, MentorsState> {
  final MentorRepository _mentorRepository;
  List<User>? _cachedMentors;

  MentorsBloc(this._mentorRepository) : super(MentorsLoading()) {
    on<GetAllMentorsEvent>(_onGetAllMentors);
    on<GetMentorByUidEvent>(_onGetMentorByUid);
    on<RefreshMentorsEvent>(_onRefreshMentors);
  }

  Future<void> _onGetAllMentors(
    GetAllMentorsEvent e,
    Emitter<MentorsState> emit,
  ) async {
    // Nếu đã có dữ liệu cache và không có search query, sử dụng cache
    if (_cachedMentors != null && e.search == null) {
      emit(MentorsLoaded(_cachedMentors!));
      return;
    }

    // Chỉ emit loading khi chưa có dữ liệu cache
    if (_cachedMentors == null) {
      emit(MentorsLoading());
    }

    try {
      final list = await _mentorRepository.getAllMentors(search: e.search);

      // Chỉ cache khi không có search query
      if (e.search == null) {
        _cachedMentors = list;
      }

      emit(MentorsLoaded(list));
    } catch (e) {
      emit(MentorsError('Không thể tải danh sách mentor: $e'));
    }
  }

  Future<void> _onGetMentorByUid(
    GetMentorByUidEvent event,
    Emitter<MentorsState> emit,
  ) async {
    try {
      emit(MentorsLoading());
      final Mentor = await _mentorRepository.getMentorByUid(event.uid);
      emit(MentorsLoaded([Mentor]));
    } catch (e) {
      emit(MentorsError('Không thể tải thông tin người dùng: $e'));
    }
  }

  Future<void> _onRefreshMentors(
    RefreshMentorsEvent event,
    Emitter<MentorsState> emit,
  ) async {
    emit(MentorsLoading());
    _cachedMentors = null;
    add(GetAllMentorsEvent());
  }
}
