import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/candidate_model.dart';
import '../services/host_service.dart';
import '../models/company_model.dart';
import '../models/reschedule_candidate.dart';

class CandidateService {
  static const String baseUrl = HostService.baseUrl;

  /// Insert reached candidate
  // static Future<bool> markCandidateReached(
  //   String userId,
  //   int candidateId,
  // ) async {
  //   final url = Uri.parse(
  //     '$baseUrl/$userId/candidate/$candidateId/reached-candidates',
  //   );
  //   final response = await http.post(url);
  //   if (response.statusCode == 201) {
  //     return true; // inserted successfully
  //   } else {
  //     // optional: you could parse response.body for error message
  //     throw Exception('Failed to mark candidate as reached: ${response.body}');
  //   }
  // }

  static Future<bool> createReachedCandidate({
    required int candidateId,
    required String status, // "SELECTED", "REJECTED", etc.
    required String token, // Bearer token
  }) async {
    final url = Uri.parse('$baseUrl/reached-candidates');

    final body = jsonEncode({
      'candidateId': candidateId,
      'status': status.toUpperCase(), // ensure uppercase like backend expects
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return true;
      // print("ReachedCandidate created: $responseData");
      // Successfully created
    } else {
      throw Exception(
        'Failed to create ReachedCandidate. Status: ${response.statusCode}, Body: ${response.body}',
      );
      return false;
    }
  }

  /// GET all candidates
  static Future<List<Map<String, dynamic>>> fetchCandidates(
    String token,
  ) async {
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
    } else if (response.statusCode == 400) {
      return [];
    } else {
      throw Exception('Failed to load candidates');
    }
  }

  /// GET candidate by ID
  static Future<Candidate> fetchCandidateById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Candidate.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load candidate with id $id');
    }
  }

  /// POST a new candidate
  static Future<bool> addCandidate(Candidate candidate) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_candidateToJson(candidate)),
    );
    return response.statusCode == 201;
  }

  /// POST update to Go For Interview
  static Future<bool> goForInterview(String clientId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/candidate/$clientId/gfi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        // or check other status codes or parse response.body if needed
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Handle exception (e.g., network error)
      print('Error in goForInterview: $e');
      return false;
    }
  }

  Future<bool> rescheduleCandidate({
    required int candidateId,
    required RescheduleCandidateDTO dto,
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/candidate/$candidateId/reschedule');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(dto.toJson()),
    );

    return response.statusCode == 200;
  }

  /// PUT or PATCH to update candidate
  // static Future<bool> updateCandidate(int id, Candidate candidate) async {
  //   final response = await http.put(
  //     Uri.parse('$baseUrl/$id/update'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(_candidateToJson(candidate)),
  //   );
  //   return response.statusCode == 200;
  // }

  // update One candidate at a time
  Future<bool> updateCandidate(
    Map<String, dynamic> candidate,
    String candidateId,
    String token,
  ) async {
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

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update candidate: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception when updating candidate: $e');
      return false;
    }
  }

  /// DELETE a candidate
  static Future<bool> deleteCandidate(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id/delete'));
    return response.statusCode == 200;
  }

  static Future<void> updateCandidateRating(
    int candidateId,
    int rating,
    String note,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/candidate/$candidateId/rating');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'rating': rating.toInt(), 'notes': note}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update candidate rating');
    }
  }

  static Future<void> deactivateCandidate(int candidateId, String token) async {
    final url = Uri.parse('$baseUrl/candidate/$candidateId/deactivate');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      throw Exception(
        'Failed to deactivate candidate. Status code: ${response.statusCode}',
      );
    }
  }

  /// Internal helper to convert model to JSON
  static Map<String, dynamic> _candidateToJson(Candidate c) {
    return {
      'id': c.id,
      'name': c.name,
      'role': c.role,
      'location': c.location,
      'qualification': c.qualification,
      'experience': c.experience,
      'age': c.age,
      'phone': c.phone,
      'rating': c.rating,
      'addedDate': c.addedDate,
      'notes': c.notes,
      'interviewTime': c.interviewTime,
    };
  }

  static Future<List<Company>> fetchCompanies(String token) async {
    final url = Uri.parse('$baseUrl/jobs');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      return data.map((jobJson) => Company.fromJson(jobJson)).toList();
    } else {
      throw Exception('Failed to load jobs: ${response.statusCode}');
    }
  }
}
