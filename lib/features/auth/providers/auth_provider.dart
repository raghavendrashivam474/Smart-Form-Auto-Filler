import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/services/api_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> init() async {
    await _apiService.init();
    if (_apiService.isAuthenticated) {
      await checkAuth();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> checkAuth() async {
    try {
      _user = await _apiService.getCurrentUser();
      _status = AuthStatus.authenticated;
      _error = null;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> login(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.login(phoneNumber);
      _user = User.fromJson(data['user']);
      _status = AuthStatus.authenticated;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }
}
