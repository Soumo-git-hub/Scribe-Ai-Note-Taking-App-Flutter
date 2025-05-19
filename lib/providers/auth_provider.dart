import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_note_taking_app/services/api_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  bool _isLoading = false;
  static const String _tokenKey = 'auth_token';
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  AuthProvider() {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      await _loadToken();
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
      _isInitialized = false;
    }
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  bool get isLoading => _isLoading;

  Future<void> _loadToken() async {
    if (!_isInitialized || _prefs == null) {
      print('SharedPreferences not initialized yet');
      return;
    }

    try {
      final token = _prefs!.getString(_tokenKey);
      if (token != null) {
        if (!JwtDecoder.isExpired(token)) {
          _token = token;
          _isAuthenticated = true;
          print('Token loaded: $token, isAuthenticated: $_isAuthenticated');
        } else {
          print('Token is expired');
          _token = null;
          _isAuthenticated = false;
          await _prefs!.remove(_tokenKey);
        }
      } else {
        print('No token found');
        _token = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      print('Error loading token: $e');
      _token = null;
      _isAuthenticated = false;
      if (_prefs != null) {
        await _prefs!.remove(_tokenKey);
      }
    }
    notifyListeners();
  }

  bool _isTokenExpired() {
    if (_token == null) return true;
    try {
      return JwtDecoder.isExpired(_token!);
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  Future<bool> login(String email, String password) async {
    if (!_isInitialized || _prefs == null) {
      await _initializePrefs();
    }

    print('Attempting login for email: $email');
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.login(email, password);
      print('Login response: $response');
      
      if (response['access_token'] != null) {
        _token = response['access_token'];
        _isAuthenticated = true;
        await _prefs!.setString(_tokenKey, _token!);
        print('Login successful, token saved');
        notifyListeners();
        return true;
      }
      print('Login failed: No token in response');
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (!_isInitialized || _prefs == null) {
      await _initializePrefs();
    }

    print('Logging out');
    _token = null;
    _isAuthenticated = false;
    await _prefs!.remove(_tokenKey);
    print('Logout complete');
    notifyListeners();
  }

  Future<bool> register(String username, String password, String email) async {
    print('Attempting to register user: $username');
    try {
      final response = await ApiService.register(username, password, email);
      print('Registration response: $response');
      
      if (response['success'] == true) {
        print('Registration successful');
        return true;
      } else {
        print('Registration failed: ${response['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<String?> getValidToken() async {
    if (!_isInitialized || _prefs == null) {
      await _initializePrefs();
    }

    if (_token == null) {
      await _loadToken();
    }
    
    if (_token == null) {
      _isAuthenticated = false;
      return null;
    }

    try {
      if (JwtDecoder.isExpired(_token!)) {
        print('Token is expired');
        _isAuthenticated = false;
        _token = null;
        await _prefs!.remove(_tokenKey);
        return null;
      }
      
      _isAuthenticated = true;
      return _token;
    } catch (e) {
      print('Error validating token: $e');
      _isAuthenticated = false;
      _token = null;
      await _prefs!.remove(_tokenKey);
      return null;
    }
  }
} 