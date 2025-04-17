import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  AuthCubit(this._firebaseAuth, this._dio) : super(AuthInitial());

  // Login function
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
          // Extract role from the response (assuming the response contains the role in the 'role' field)
          String role =
              response
                  .data['role']; // Adjust based on your API response structure
          print('User role: $role'); // Print the role to the console

          emit(AuthSuccess(user!));
        } else {
          // Gửi API thất bại
          print('API Error: Status Code ${response.statusCode}');
          emit(
            AuthFailure(
              'Failed to send data to API. Status Code: ${response.statusCode}',
            ),
          );
        }
      } else {
        // UID hoặc token null
        print('Error: UID or Token is null');
        emit(AuthFailure('UID or token is null'));
      }
    } on FirebaseAuthException catch (e) {
      // Lỗi Firebase
      print('Firebase Auth Error: ${e.message}');
      emit(AuthFailure('Firebase login failed: ${e.message}'));
    } catch (e) {
      // Lỗi bất kỳ khác
      print('Unexpected Error: ${e.toString()}');
      emit(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
