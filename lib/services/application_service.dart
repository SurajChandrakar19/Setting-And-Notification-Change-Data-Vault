import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/host_service.dart';

// Remove these if not used:
import '../services/token_service.dart'; // Import TokenService for token management
// import 'dart:html' as html;

class ReachedCandidateService {
  static const String baseUrl = HostService.baseUrl;

  // using
  static Future<List<Map<String, dynamic>>> fetchReachedCandidates() async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) throw Exception("No valid token available");

    final response = await http.get(
      Uri.parse('$baseUrl/reached-candidates'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception(
        'Failed to load reached candidates. Code: ${response.statusCode}',
      );
    }
  }
}

class CandidateTrackService {
  static const String baseUrl = HostService.baseUrl;

  // using
  static Future<bool> updateStatus({
    required int candidateId,
    required String userId,
    required String status,
  }) async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) throw Exception("No valid token available");

    final url = Uri.parse('$baseUrl/applications');
    final body = jsonEncode({
      'candidateId': candidateId,
      'userId': userId,
      'status': status.toUpperCase(),
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Exception during updateStatus: $e');
      return false;
    }
  }
}
