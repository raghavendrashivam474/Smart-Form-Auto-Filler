import 'package:flutter/material.dart';
import '../../../core/models/form_model.dart';
import '../../../core/services/api_service.dart';

class FormsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<FormModel> _forms = [];
  FormModel? _currentForm;
  bool _isLoading = false;
  String? _error;

  List<FormModel> get forms => _forms;
  FormModel? get currentForm => _currentForm;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadForms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _forms = await _apiService.getForms();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadForm(String formId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentForm = await _apiService.getForm(formId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFieldValue(String fieldId, dynamic value) {
    if (_currentForm != null) {
      final fields = _currentForm!.fields.map((field) {
        if (field.id == fieldId) {
          return field.copyWith(value: value);
        }
        return field;
      }).toList();

      _currentForm = FormModel(
        formId: _currentForm!.formId,
        title: _currentForm!.title,
        fields: fields,
        stats: _currentForm!.stats,
      );

      notifyListeners();
    }
  }

  Map<String, dynamic> getFormData() {
    if (_currentForm == null) return {};

    final data = <String, dynamic>{};
    for (var field in _currentForm!.fields) {
      if (field.value != null) {
        data[field.id] = field.value;
      }
    }
    return data;
  }

  void clearCurrentForm() {
    _currentForm = null;
    notifyListeners();
  }
}
