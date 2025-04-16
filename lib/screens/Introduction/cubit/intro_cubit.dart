import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// States for IntroCubit
abstract class IntroState {}

class IntroInitial extends IntroState {}

class IntroViewed extends IntroState {}

class IntroCubit extends Cubit<IntroState> {
  IntroCubit() : super(IntroInitial());

  // Kiểm tra xem intro đã được xem chưa
  Future<void> checkIntroStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool introSeen =
        prefs.getBool('intro_seen') ?? false; // Default to false if not set

    if (introSeen) {
      emit(
        IntroViewed(),
      ); // Nếu đã xem intro, chuyển sang trạng thái IntroViewed
    } else {
      emit(IntroInitial()); // Nếu chưa xem intro, vẫn ở trạng thái IntroInitial
    }
  }

  // Đánh dấu intro đã xem
  Future<void> markIntroAsViewed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_seen', true); // Lưu trạng thái intro đã được xem
    emit(IntroViewed()); // Cập nhật trạng thái IntroViewed
  }
}
