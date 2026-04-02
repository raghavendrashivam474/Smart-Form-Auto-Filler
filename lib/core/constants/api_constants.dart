class ApiConstants {
  // Base URL - localhost for web/desktop, 10.0.2.2 for Android emulator
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Endpoints
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String profile = '/profile';
  static const String forms = '/forms';
  static const String submissions = '/submissions';
  
  // Timeout
  static const Duration timeout = Duration(seconds: 30);
  
  // Get PDF download URL
  static String getPdfDownloadUrl(String submissionId) {
    return 'http://localhost:5000/uploads/pdfs/submission-$submissionId.pdf';
  }
}
