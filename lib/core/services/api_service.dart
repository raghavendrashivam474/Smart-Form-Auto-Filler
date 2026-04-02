import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/user.dart';
import '../models/form_model.dart';
import '../models/submission.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Login
  Future<Map<String, dynamic>> login(String phoneNumber) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
            headers: _headers,
            body: jsonEncode({'phoneNumber': phoneNumber}),
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await saveToken(data['data']['token']);
        return data['data'];
      }

      throw Exception(data['message'] ?? 'Login failed');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Current User
  Future<User> getCurrentUser() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.me}'),
            headers: _headers,
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return User.fromJson(data['data']);
      }

      throw Exception(data['message'] ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Profile
  Future<UserProfile?> getProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
            headers: _headers,
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        if (data['data'] != null && data['data'].isNotEmpty) {
          return UserProfile.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update Profile
  Future<UserProfile> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
            headers: _headers,
            body: jsonEncode(profileData),
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return UserProfile.fromJson(data['data']);
      }

      throw Exception(data['message'] ?? 'Failed to update profile');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get All Forms
  Future<List<FormModel>> getForms() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.forms}'),
            headers: _headers,
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return (data['data'] as List)
            .map((form) => FormModel.fromJson(form))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Form with Auto-fill
  Future<FormModel> getForm(String formId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.forms}/$formId'),
            headers: _headers,
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return FormModel.fromJson(data['data']);
      }

      throw Exception(data['message'] ?? 'Failed to get form');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Submit Form
  Future<Submission> submitForm(
    String formId,
    Map<String, dynamic> formData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.submissions}'),
            headers: _headers,
            body: jsonEncode({
              'formId': formId,
              'data': formData,
              'documents': [],
            }),
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return Submission.fromJson(data['data']);
      }

      throw Exception(data['message'] ?? 'Failed to submit form');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Submissions
  Future<List<Submission>> getSubmissions() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.submissions}'),
            headers: _headers,
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return (data['data'] as List)
            .map((sub) => Submission.fromJson(sub))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Generate PDF
  Future<String> generatePDF(String submissionId) async {
    try {
      final response = await http
          .post(
            Uri.parse(
                '${ApiConstants.baseUrl}${ApiConstants.submissions}/$submissionId/pdf'),
            headers: _headers,
          )
          .timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return data['data']['pdfUrl'];
      }

      throw Exception(data['message'] ?? 'Failed to generate PDF');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await clearToken();
  }
}
