class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);
  
  // Auth endpoints
  static const String sendOTP = '/auth/send-otp';
  static const String verifyOTP = '/auth/verify-otp';
  static const String me = '/auth/me';
  static const String sendOtp = '/auth/send-otp'; // Alias
  static const String verifyOtp = '/auth/verify-otp'; // Alias
  static const String getMe = '/auth/me'; // Alias
  
  // Profile endpoints
  static const String profile = '/profile';
  
  // Forms endpoints
  static const String forms = '/forms';
  
  // Submissions endpoints
  static const String submissions = '/submissions';
  
  // Mapping endpoints
  static const String mappingDetect = '/mapping/detect';
  static const String mappingSave = '/mapping/save';
  static const String mappingUser = '/mapping/user';
  
  // Document endpoints
  static const String documentUpload = '/documents/upload';
  static const String documentCreateForm = '/documents/create-form';
}