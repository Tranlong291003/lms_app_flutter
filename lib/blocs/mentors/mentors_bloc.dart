import 'package:bloc/bloc.dart';
import 'package:lms/blocs/mentors/mentors_event.dart';
import 'package:lms/blocs/mentors/mentors_state.dart';
import 'package:lms/repository/mentor_repository.dart';

class MentorsBloc extends Bloc<MentorsEvent, MentorsState> {
  final MentorRepository _mentorRepository;

  MentorsBloc(this._mentorRepository) : super(MentorsLoading()) {
    on<GetAllMentorsEvent>(_onGetAllMentors);
  }

  Future<void> _onGetAllMentors(
    GetAllMentorsEvent e,
    Emitter<MentorsState> emit,
  ) async {
    emit(MentorsLoading());
    try {
      final list = await _mentorRepository.getAllMentors(search: e.search);

      emit(MentorsLoaded(list));
    } catch (e) {
      emit(MentorsError('Không thể tải danh sách mentor: $e'));
    }
  }
}
