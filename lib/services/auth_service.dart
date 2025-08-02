import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_login_response.dart'; // adjust path as needed
import 'package:google_sign_in/google_sign_in.dart';
import '../services/host_service.dart';

class AuthService {
  static const String baseUrl = HostService.baseUrlAuth;

  Future<UserLoginResponse?> login(String email, String password) async {
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
}

class OAuth2Service {
  static const String _baseUrl = 'http://localhost:8080/v1/oauth2';

  static Future<Map<String, dynamic>> oauth2Login({
    required String provider,
    required String accessToken,
    required String email,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
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
