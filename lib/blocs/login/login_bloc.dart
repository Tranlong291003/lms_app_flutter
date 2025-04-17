// // lib/blocs/login/login_bloc.dart
// import 'package:bloc/bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:dio/dio.dart';
// import 'login_event.dart';
// import 'login_state.dart';

// class LoginBloc extends Bloc<LoginEvent, LoginState> {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final Dio _dio = Dio();

//   LoginBloc() : super(LoginInitial()) {
//     // Lắng nghe sự kiện đăng nhập
//     on<LoginButtonPressed>(_onLoginButtonPressed);
//   }

//   Future<void> _onLoginButtonPressed(
//     LoginButtonPressed event,
//     Emitter<LoginState> emit,
//   ) async {
//     try {
//       emit(LoginLoading());

//       // 1. Đăng nhập Firebase
//       UserCredential userCredential = await _firebaseAuth
//           .signInWithEmailAndPassword(
//             email: event.email,
//             password: event.password,
//           );

//       // 2. Lấy ID token từ user
//       String? token = await userCredential.user?.getIdToken();
//       if (token == null) {
//         emit(const LoginFailure(error: 'Không lấy được Firebase token'));
//         return;
//       }

//       // 3. Gửi token lên server Node.js qua Dio
//       final response = await _dio.post(
//         'https://your-server-domain.com/api/auth/login',
//         data: {'email': event.email, 'firebaseToken': token},
//         options: Options(headers: {'Content-Type': 'application/json'}),
//       );

//       if (response.statusCode == 200) {
//         // Tuỳ logic, nếu server trả về success -> emit(LoginSuccess)
//         emit(const LoginSuccess(message: 'Đăng nhập thành công!'));
//       } else {
//         emit(LoginFailure(error: 'Server trả về mã ${response.statusCode}'));
//       }
//     } on FirebaseAuthException catch (e) {
//       emit(LoginFailure(error: 'Lỗi Firebase Auth: ${e.message}'));
//     } catch (e) {
//       emit(LoginFailure(error: 'Lỗi khác: $e'));
//     }
//   }
// }
