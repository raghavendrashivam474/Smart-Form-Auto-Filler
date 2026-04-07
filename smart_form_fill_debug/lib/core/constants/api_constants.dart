class ApiConstants {
  // ✅ PRODUCTION URL - Works anywhere!
  static const String baseUrl = 'https://smart-form-auto-filler-production.up.railway.app/api';
  
  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);
  
  // Auth endpoints
  static const String sendOTP = '/auth/send-otp';
  static const String verifyOTP = '/auth/verify-otp';
  static const String me = '/auth/me';
  
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