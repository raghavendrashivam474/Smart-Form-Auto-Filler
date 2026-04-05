import '../../../core/services/api_service.dart';

class MappingService {
  final ApiService _apiService = ApiService();

  // Detect mapping for unknown form
  Future<Map<String, dynamic>?> detectMapping(List<dynamic> fields) async {
    try {
      final response = await _apiService.post('/mapping/detect', {
        'fields': fields,
      });

      if (response != null && response['success'] == true) {
        return response;
      }
      return null;
    } catch (e) {
      print('Error detecting mapping: $e');
      return null;
    }
  }

  // Save confirmed mapping
  Future<bool> saveMapping(
    String formHash,
    String formName,
    Map<String, String> mapping,
  ) async {
    try {
      final response = await _apiService.post('/mapping/save', {
        'formHash': formHash,
        'formName': formName,
        'mapping': mapping,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error saving mapping: $e');
      return false;
    }
  }
}