// lib/services/base_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseService {
  final Dio _dio;
  static const String _tokenKey = 'auth_token';
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _isHandlingTokenError = false;

  BaseService({String? token})
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      ) {
    _setupInterceptors();
    _initTokenFromPrefs();
  }

  Future<void> _initTokenFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('[ERR] Failed to load token: $e');
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 && !_isHandlingTokenError) {
            await handleTokenError();
            return handler.reject(e);
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> handleTokenError() async {
    if (_isHandlingTokenError) return;

    try {
      _isHandlingTokenError = true;
      await clearToken();

      final context = navigatorKey.currentContext;
      if (context != null) {
        await context.read<AuthCubit>().logout();
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            context.read<AuthCubit>().logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      print('[ERR] Failed to handle token error: $e');
    } finally {
      _isHandlingTokenError = false;
    }
  }

  Future<void> setToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } catch (e) {
      print('[ERR] Failed to save token: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('[ERR] Failed to get token: $e');
      return null;
    }
  }

  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      _dio.options.headers.remove('Authorization');
    } catch (e) {
      print('[ERR] Failed to clear token: $e');
    }
  }

  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.post(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.put(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.patch(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.delete(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );
}
