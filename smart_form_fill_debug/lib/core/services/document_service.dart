import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentService {
  final Dio _dio = Dio();

  DocumentService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Upload document for OCR processing
  Future<Map<String, dynamic>> uploadDocument(File file) async {
    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      // Get file extension
      final ext = file.path.split('.').last.toLowerCase();
      
      // Determine MIME type
      String mimeType;
      if (ext == 'pdf') {
        mimeType = 'application/pdf';
      } else if (ext == 'jpg' || ext == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (ext == 'png') {
        mimeType = 'image/png';
      } else {
        throw Exception('Unsupported file type. Use PDF, JPG, or PNG');
      }

      // Create multipart file
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      print('📤 Uploading: $fileName ($mimeType)');

      // Upload with auth header
      final response = await _dio.post(
        ApiConstants.documentUpload,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(0);
          print('Upload progress: $progress%');
        },
      );

      print('✅ Upload response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Dio error: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Upload failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Upload error: $e');
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Create form from detected fields
  Future<Map<String, dynamic>> createFormFromFields({
    required String name,
    required String description,
    required List<Map<String, dynamic>> fields,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _dio.post(
        ApiConstants.documentCreateForm,
        data: {
          'name': name,
          'description': description,
          'fields': fields,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      print('❌ Create form error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to create form');
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Failed to create form: $e');
    }
  }
}