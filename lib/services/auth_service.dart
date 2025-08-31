import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_login_response.dart'; // adjust path as needed
import 'package:google_sign_in/google_sign_in.dart';
import '../services/host_service.dart';
import '../providers/user_provider.dart';
import '../utils/token_storage.dart';

class OAuth2Service {
  static const String _baseUrl = HostService.baseUrl;

  // using
  static Future<Map<String, dynamic>> oauth2Login({
    required String provider,
    required String accessToken,
    required String email,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/oauth2/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provider': provider,
        'accessToken': accessToken,
        'email': email,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('OAuth2 login failed');
    }
  }
}

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '191138179324-svfopo53c8sb3r222khlo0aqo003re61.apps.googleusercontent.com',
  );

  // using
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    return await _googleSignIn.signIn();
  }

  Future<String?> getAccessToken(GoogleSignInAccount user) async {
    final auth = await user.authentication;
    return auth.accessToken;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

class AuthService {
  static const String baseUrl = HostService.baseUrlAuth;

  // using
  Future<UserLoginResponse?> login(String email, String password) async {
    // your existing login
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return UserLoginResponse.fromJson(jsonBody);
      } else {
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // using
  /// Logout user → revoke backend session + clear local tokens
  static Future<bool> handleLogout(UserProvider userProvider) async {
    try {
      final accessToken = (await TokenStorage.getTokens())['accessToken'];

      if (accessToken != null && accessToken.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        // ignore backend failure → still clear locally
        if (response.statusCode != 200) {
          debugPrint("Server logout failed, clearing local session anyway");
        }
      }

      // ✅ Always clear local session
      await userProvider.clearUser();

      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
  }
}
