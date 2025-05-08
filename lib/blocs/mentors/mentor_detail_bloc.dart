import 'package:bloc/bloc.dart';
import 'package:lms/blocs/mentors/mentors_event.dart';
import 'package:lms/blocs/mentors/mentors_state.dart';
import 'package:lms/repository/mentor_repository.dart';

class MentorDetailBloc extends Bloc<MentorsEvent, MentorsState> {
  final MentorRepository mentorRepository;

  MentorDetailBloc(this.mentorRepository) : super(MentorsLoading()) {
    on<GetMentorByUidEvent>(_onGetMentorByUid);
  }

  Future<void> _onGetMentorByUid(
    GetMentorByUidEvent event,
    Emitter<MentorsState> emit,
  ) async {
    try {
      emit(MentorsLoading());
      final mentor = await mentorRepository.getMentorByUid(event.uid);
      emit(MentorsLoaded([mentor]));
    } catch (e) {
      emit(MentorsError('Không thể tải thông tin người dùng: $e'));
    }
  }
}
