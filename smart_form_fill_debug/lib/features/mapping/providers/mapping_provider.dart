import 'package:flutter/foundation.dart';
import '../services/mapping_service.dart';

class MappingProvider with ChangeNotifier {
  final MappingService _mappingService = MappingService();

  bool _isLoading = false;
  Map<String, dynamic>? _currentDetection;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentDetection => _currentDetection;
  String? get errorMessage => _errorMessage;

  // Detect mapping for form fields
  Future<Map<String, dynamic>?> detectMapping(List<dynamic> fields) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _mappingService.detectMapping(fields);
      _currentDetection = result;
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save mapping
  Future<bool> saveMapping(
    String formHash,
    String formName,
    Map<String, String> mapping,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _mappingService.saveMapping(
        formHash,
        formName,
        mapping,
      );
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}