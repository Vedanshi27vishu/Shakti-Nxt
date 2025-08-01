import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthHelper {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _userIdKey = 'user_id';

  // Save login response data
  static Future<void> saveLoginData(Map<String, dynamic> loginResponse) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save token
    if (loginResponse.containsKey('token')) {
      await prefs.setString(_tokenKey, loginResponse['token']);
    }
    
    // Save user data
    if (loginResponse.containsKey('user')) {
      final userData = loginResponse['user'];
      await prefs.setString(_userKey, json.encode(userData));
      
      // Save user ID separately for easy access
      if (userData.containsKey('id')) {
        await prefs.setString(_userIdKey, userData['id']);
      }
    }
    
    print('Login data saved successfully');
    print('Token: ${loginResponse['token']}');
    print('User ID: ${loginResponse['user']?['id']}');
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all auth data (for logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_userIdKey);
  }

  // Debug method to check stored data
  static Future<void> debugAuthData() async {
    final token = await getToken();
    final userData = await getUserData();
    final userId = await getUserId();
    
    print('=== AUTH DEBUG ===');
    print('Token: $token');
    print('User Data: $userData');
    print('User ID: $userId');
    print('================');
  }
}