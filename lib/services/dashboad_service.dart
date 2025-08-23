import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/go_for_interview_response.dart';
import '../models/dashboard_model.dart';
import '../services/host_service.dart';
import '../services/token_service.dart';

class DashboardService {
  static const String baseUrl = HostService.baseUrl;

  // this is for count how may cnadidate reached (attended candidate)

  // When Homw page load it automaticaly load
  static Future<DashboardSummaryResponse> getDashboardSummary(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId/dashboard/summary'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return DashboardSummaryResponse.fromJson(jsonData);
      } else {
        throw Exception("Failed to load dashboard summary");
      }
    } catch (e) {
      print('Error fetching dashboard summary: $e');
      rethrow;
    }
  }

  // When click on Home page view this will work for Go For Interview
  static Future<List<GoForInterviewResponse>> fetchGFICandidates() async {
    final token = await TokenService.getValidAccessToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/gfi'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => GoForInterviewResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load GFI candidates');
      }
    } catch (e) {
      print('Error fetching GFI candidates: $e');
      rethrow;
    }
  }

  // When click on Home page view this will work for Attendance Marking
  static Future<List<GoForInterviewResponse>>
  fetchAttendanceCandidates() async {
    final token = await TokenService.getValidAccessToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reached-candidates'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => GoForInterviewResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load Attendance Marking candidates');
      }
    } catch (e) {
      print('Error fetching Attendance Marking candidates: $e');
      rethrow;
    }
  }

  // When click on update button on targer
  Future<void> updateTargetValue({
    required String userId,
    required int targetValue,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/$userId/dashboard/targets/update?userid=$userId&targetValue=$targetValue',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      print('Target value updated successfully');
    } else {
      throw Exception('Failed to update target');
    }
  }

  // Fetch users for Set Target functionality
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final token = await TokenService.getValidAccessToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/with-target'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  // Set target for a user it
  static Future<void> createTarget({
    required String userId,
    required int newTarget,
  }) async {
    final token = await TokenService.getValidAccessToken();
    final url = Uri.parse(
      '$baseUrl/targets/current-month?userid=$userId&targetValue=$newTarget',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      print('Target updated successfully');
    } else {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update target');
    }
  }
}
