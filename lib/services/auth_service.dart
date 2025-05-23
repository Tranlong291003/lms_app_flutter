import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:lms/services/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends BaseService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  final FirebaseAuth _firebaseAuth;
  final FirebaseMessaging _firebaseMessaging;

  AuthService(this._firebaseAuth, this._firebaseMessaging) : super();

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Đăng ký Firebase thất bại');
      }

      final idToken = await userCredential.user!.getIdToken();
      final fcmToken = await _firebaseMessaging.getToken();

      final response = await post(
        ApiConfig.signUp,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'idToken': idToken,
          'fcmToken': fcmToken,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Đăng ký thất bại: ${response.statusCode}');
    } catch (e) {
      await _firebaseAuth.currentUser?.delete();
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Đăng nhập Firebase thất bại');
      }

      final idToken = await userCredential.user!.getIdToken();
      final fcmToken = await _firebaseMessaging.getToken();

      final response = await post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
          'idToken': idToken,
          'fcmToken': fcmToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null) {
          await setToken(token);
        }
        return data;
      }
      throw Exception('Đăng nhập thất bại: ${response.statusCode}');
    } catch (e) {
      await _firebaseAuth.signOut();
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await get('/api/auth/me');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Không thể lấy thông tin user: ${response.statusCode}');
    } catch (e) {
      throw Exception('Không thể lấy thông tin user: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await clearToken();
    } catch (e) {
      throw Exception('Đăng xuất thất bại: $e');
    }
  }

  Future<void> logoutWithContext(BuildContext context) async {
    try {
      await logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đăng xuất thất bại: $e')));
      }
    }
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) {
      return await refreshToken();
    }
    return token;
  }

  @override
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<String?> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      if (refreshToken == null) {
        return null;
      }
      return null; // Vì không có API refresh
    } catch (e) {
      return null;
    }
  }

  Future<void> checkTokenExpiration(BuildContext context) async {
    try {
      final token = await getToken();
      if (token == null) {
        await logoutWithContext(context);
        return;
      }

      final response = await get('/api/auth/verify-token');
      if (response.statusCode != 200) {
        await logoutWithContext(context);
      }
    } catch (e) {
      await logoutWithContext(context);
    }
  }
}
