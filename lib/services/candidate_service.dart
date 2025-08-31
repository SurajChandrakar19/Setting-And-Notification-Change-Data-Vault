import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/candidate_model.dart';
import '../models/company_model.dart';
import '../models/reschedule_candidate.dart';
import '../services/host_service.dart';
import '../services/token_service.dart';

class CandidateService {
  static const String baseUrl = HostService.baseUrl;

  // using
  /// Insert reached candidate (old way was manual userId, now handled server side)
  static Future<bool> createReachedCandidate({
    required int candidateId,
    required String status, // "SELECTED", "REJECTED", etc.
  }) async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) throw Exception("No valid token available");

    final url = Uri.parse('$baseUrl/reached-candidates');
    final body = jsonEncode({
      'candidateId': candidateId,
      'status': status.toUpperCase(),
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    return response.statusCode == 200;
  }

  // using
  /// GET all unreached candidates
  static Future<List<Map<String, dynamic>>> fetchCandidates() async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) throw Exception("No valid token available");

    final response = await http.get(
      Uri.parse('$baseUrl/candidate/unreached'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load candidates');
    }
  }

  // using
  /// POST update to Go For Interview
  static Future<bool> goForInterview(String clientId) async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) throw Exception("No valid token available");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/candidate/$clientId/gfi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Error in goForInterview: $e');
      return false;
    }
  }

  // using
  /// PUT reschedule
  static Future<bool> rescheduleCandidate({
    required int candidateId,
    required RescheduleCandidateDTO dto,
  }) async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) throw Exception("No valid token available");

    final url = Uri.parse('$baseUrl/candidate/$candidateId/reschedule');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    return response.statusCode == 200;
  }

  // using
  /// Update one candidate at a time
  static Future<bool> updateCandidate({
    required Map<String, dynamic> candidate,
    required String candidateId,
  }) async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) throw Exception("No valid token available");

    try {
      final url = Uri.parse('$baseUrl/candidate/$candidateId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(candidate),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Exception when updating candidate: $e');
      return false;
    }
  }

  // using
  /// Update rating
  static Future<void> updateCandidateRating({
    required int candidateId,
    required int rating,
    required String note,
  }) async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) throw Exception("No valid token available");

    final url = Uri.parse('$baseUrl/candidate/$candidateId/rating');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'rating': rating, 'notes': note}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update candidate rating');
    }
  }

  // using
  /// Deactivate candidate
  static Future<void> deactivateCandidate(int candidateId) async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) throw Exception("No valid token available");

    final url = Uri.parse('$baseUrl/candidate/$candidateId/deactivate');
    final response = await http.put(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to deactivate candidate. Status code: ${response.statusCode}',
      );
    }
  }

  // using
  /// Fetch companies
  static Future<List<Company>> fetchCompanies() async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) throw Exception("No valid token available");

    final url = Uri.parse('$baseUrl/jobs');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((jobJson) => Company.fromJson(jobJson)).toList();
    } else {
      throw Exception('Failed to load jobs: ${response.statusCode}');
    }
  }
}
