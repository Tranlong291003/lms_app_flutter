// lib/services/category_service.dart
import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';

class CategoryService {
  final Dio _dio;
  CategoryService(Dio dio) : _dio = dio {
    // // Nếu chưa thêm, bạn có thể bật interceptor để log request/response:
    // _dio.interceptors.add(
    //   LogInterceptor(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: true,
    //     responseHeader: false,
    //     error: true,
    //     logPrint: (obj) => print('🦄 [Dio] $obj'),
    //   ),
    // );
  }

  /// Lấy danh sách tất cả category dưới dạng JSON Map
  Future<List<Map<String, dynamic>>> fetchAllCategory() async {
    try {
      final url = '${_dio.options.baseUrl}${ApiConfig.getAllCategory}';
      // print('➡️ [CategoryService] GET $url');

      final res = await _dio.get(ApiConfig.getAllCategory);
      // print('⬅️ [CategoryService] status: ${res.statusCode}');
      // print('⬅️ [CategoryService] data.runtimeType: ${res.data.runtimeType}');
      // print('⬅️ [CategoryService] data: ${res.data}');

      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, dynamic>>.from(res.data as List);
      }
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['data'] is List) {
          // print('🟢 [CategoryService] found list in map["data"]');
          return List<Map<String, dynamic>>.from(map['data'] as List);
        }
      }

      throw Exception(
        'Không thể tải danh sách category '
        '(status: ${res.statusCode}, '
        'kiểu trả về: ${res.data.runtimeType})',
      );
    } on DioException catch (e) {
      print(
        '❌ [CategoryService] DioError type=${e.type}, message=${e.message}',
      );
      if (e.response != null) {
        print('❌ [CategoryService] response data: ${e.response?.data}');
      }
      throw Exception('Lỗi Dio khi tải category: ${e.message}');
    } catch (e) {
      print('❌ [CategoryService] Unknown error: $e');
      throw Exception('Lỗi không xác định khi tải category: $e');
    }
  }
}
