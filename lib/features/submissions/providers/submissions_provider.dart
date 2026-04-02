import 'package:flutter/material.dart';
import '../../../core/models/submission.dart';
import '../../../core/services/api_service.dart';

class SubmissionsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Submission> _submissions = [];
  bool _isLoading = false;
  String? _error;

  List<Submission> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSubmissions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _submissions = await _apiService.getSubmissions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Submission?> submitForm(
    String formId,
    Map<String, dynamic> formData,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final submission = await _apiService.submitForm(formId, formData);
      _submissions.insert(0, submission);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return submission;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> generatePDF(String submissionId) async {
    try {
      final pdfUrl = await _apiService.generatePDF(submissionId);
      
      // Update submission with PDF URL
      final index = _submissions.indexWhere((s) => s.id == submissionId);
      if (index != -1) {
        final updatedSubmission = Submission(
          id: _submissions[index].id,
          formId: _submissions[index].formId,
          formTitle: _submissions[index].formTitle,
          data: _submissions[index].data,
          pdfUrl: pdfUrl,
          status: _submissions[index].status,
          createdAt: _submissions[index].createdAt,
        );
        _submissions[index] = updatedSubmission;
        notifyListeners();
      }

      return pdfUrl;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
