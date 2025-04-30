import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

      // Đăng nhập Firebase
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Lấy UID và token
      User? user = userCredential.user;
      String? uid = user?.uid;
      String? idToken = await user?.getIdToken();

      if (uid != null && idToken != null) {
        // Lấy FCM Token
        String? fcmToken = await FirebaseMessaging.instance.getToken();

        // Gửi UID, idToken và fcmToken lên API dưới dạng JSON
        Response response = await _dio.post(
          ApiConfig.login, // Địa chỉ API của bạn
          data: {
            'uid': uid,
            'idToken': idToken,
            'fcmToken': fcmToken, // Gửi FCM Token
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json', // Đảm bảo là JSON
            },
          ),
        );

        // Xử lý response từ API
        if (response.statusCode == 200) {
          bool success = response.data['success'] ?? false;
          if (!success) {
            await _firebaseAuth.signOut(); // Gọi hàm đăng xuất khi có lỗi
            emit(
              AuthFailure(
                'Tài khoản đã bị khoá, vui lòng liên hệ admin để được xử lý',
              ),
            );
          } else {
            String role = response.data['role'] ?? 'Unknown';

            // Lưu role và fcmToken vào SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('role', role); // Lưu role
            prefs.setString('fcmToken', fcmToken ?? ''); // Lưu fcmToken

            print('Role: $role');
            emit(AuthSuccess(user!)); // Đăng nhập thành công
          }
        } else {
          await _firebaseAuth.signOut(); // Gọi hàm đăng xuất khi có lỗi
          emit(AuthFailure('Đăng nhập thất bại, vui lòng thử lại'));
        }
      } else {
        await _firebaseAuth.signOut(); // Gọi hàm đăng xuất khi có lỗi
        emit(AuthFailure('Đăng nhập thất bại, vui lòng thử lại'));
      }
    } on FirebaseAuthException catch (e) {
      // Lỗi Firebase
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        emit(AuthFailure('Tài khoản hoặc mật khẩu không đúng'));
      } else {
        emit(AuthFailure('Đăng nhập thất bại, vui lòng thử lại sau'));
      }
      await _firebaseAuth.signOut(); // Gọi hàm đăng xuất khi có lỗi
    } catch (e) {
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

  // Hàm lấy FCM Token từ SharedPreferences
  Future<String?> getFcmTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcmToken');
  }
}
