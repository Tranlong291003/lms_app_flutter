import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  AuthCubit(this._firebaseAuth, this._dio) : super(AuthInitial());

  // Hàm đăng nhập
  Future<void> loginWithEmailPassword(String email, String password) async {
    try {
      emit(AuthLoading());

      // Đăng nhập với email và mật khẩu
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Lấy UID và token
      User? user = userCredential.user;
      String? uid = user?.uid;
      String? idToken = await user?.getIdToken();

      if (uid != null && idToken != null) {
        // Gửi UID và token lên API dưới dạng JSON
        Response response = await _dio.post(
          ApiConfig.login, // Địa chỉ API của bạn
          data: {'uid': uid, 'idToken': idToken},
          options: Options(
            headers: {
              'Content-Type': 'application/json', // Đảm bảo là JSON
            },
          ),
        );

        // Xử lý response từ API
        if (response.statusCode == 200) {
          // Kiểm tra xem API có trả về success = false không
          bool success = response.data['success'] ?? false;
          if (!success) {
            // Tài khoản bị khóa, chỉ hiển thị thông báo đăng nhập thất bại
            await _firebaseAuth.signOut(); // Gọi hàm đăng xuất khi có lỗi
            emit(
              AuthFailure(
                'Tài khoản đã bị khoá, vui lòng liên hệ admin để được xử lý',
              ),
            );
          } else {
            // Nếu success = true, lấy thông tin role từ response
            String role =
                response.data['role'] ??
                'Unknown'; // Điều chỉnh theo cấu trúc phản hồi API của bạn

            // Lưu role vào SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('role', role); // Lưu role

            print('Role: $role'); // In role ra console

            emit(AuthSuccess(user!)); // Đăng nhập thành công
          }
        } else {
          // Nếu API trả về bất kỳ mã trạng thái nào khác ngoài 200
          await _firebaseAuth.signOut(); // Gọi hàm đăng xuất khi có lỗi
          emit(AuthFailure('Đăng nhập thất bại, vui lòng thử lại'));
        }
      } else {
        // Nếu UID hoặc Token là null
        await _firebaseAuth.signOut(); // Gọi hàm đăng xuất khi có lỗi
        emit(AuthFailure('Đăng nhập thất bại, vui lòng thử lại'));
      }
    } on FirebaseAuthException catch (e) {
      // Lỗi Firebase
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        // Nếu tài khoản hoặc mật khẩu sai
        emit(AuthFailure('Tài khoản hoặc mật khẩu không đúng'));
      } else {
        // Các lỗi khác của Firebase
        emit(AuthFailure('Đăng nhập thất bại, vui lòng thử lại sau'));
      }
      await _firebaseAuth.signOut(); // Gọi hàm đăng xuất khi có lỗi
    } catch (e) {
      // Lỗi bất kỳ khác
      print('Lỗi không xác định: $e');
      await _firebaseAuth.signOut(); // Gọi hàm đăng xuất khi có lỗi
      emit(AuthFailure('Đăng nhập thất bại, vui lòng thử lại sau'));
    }
  }

  // Hàm lấy role từ SharedPreferences
  Future<String?> getRoleFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
}
