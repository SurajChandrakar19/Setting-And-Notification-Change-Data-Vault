import 'package:file_picker/file_picker.dart';

import '../models/company_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/company_id_name_model.dart';
import '../models/candidate_create_model.dart';
import '../models/create_candidate_response.dart';
import 'package:http_parser/http_parser.dart';
import '../models/create_candidate_with_resume.dart';
import 'package:mime/mime.dart'; // for lookupMimeType
// for basename
import '../services/host_service.dart'; // Ensure you have this import for baseUrl
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../services/token_service.dart';
// For non-web platforms

class AddCandidateService {
  static const String baseUrl = HostService.baseUrl;

  // using
  static Future<List<CompanyIdName>> fetchJobIdAndCompanyNames() async {
    final url = Uri.parse('$baseUrl/candidates/companies');
    final token = await TokenService.getValidAccessToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => CompanyIdName.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load job company names');
    }
  }

  // using
  static Future<String> uploadCandidateWithResume({
    required CandidateCreateWithResumeDTO candidate,
    PlatformFile? resumeFile, // Use PlatformFile for cross-platform support
  }) async {
    final token = await TokenService.getValidAccessToken();
    final uri = Uri.parse('$baseUrl/candidate/create-with-resume');
    final request = http.MultipartRequest('POST', uri);

    // Candidate JSON data
    final jsonCandidate = jsonEncode(candidate.toJson());
    request.fields['candidateData'] = jsonCandidate;

    // Optional resume file
    if (resumeFile != null) {
      final mimeType =
          lookupMimeType(resumeFile.name) ?? 'application/octet-stream';

      http.MultipartFile multipartFile;

      if (kIsWeb) {
        // ✅ Web: Use fromBytes
        multipartFile = http.MultipartFile.fromBytes(
          'resumeFile',
          resumeFile.bytes!,
          filename: resumeFile.name,
          contentType: MediaType.parse(mimeType),
        );
      } else {
        // ✅ Mobile/Desktop: Use fromPath
        multipartFile = await http.MultipartFile.fromPath(
          'resumeFile',
          resumeFile.path!,
          filename: resumeFile.name,
          contentType: MediaType.parse(mimeType),
        );
      }

      request.files.add(multipartFile);
    }

    // Add JWT token
    request.headers['Authorization'] = 'Bearer $token';

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        return "Candidate created successfully";
      } else {
        try {
          final decoded = jsonDecode(respStr);
          return decoded['message'] ?? 'Failed to upload candidate';
        } catch (e) {
          return 'Upload failed (status ${response.statusCode})';
        }
      }
    } catch (e) {
      return 'Error sending request: ${e.toString()}';
    }
  }

  // using
  // Method to check if a phone number is already taken
  static Future<bool> isPhoneNumberTaken(String phone) async {
    final token = await TokenService.getValidAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/candidate/check-by-phone?phone=$phone'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // Add token if needed:
        // 'Authorization': 'Bearer YOUR_TOKEN',
      },
    );

    if (response.statusCode == 200) {
      return false; // Phone number is available
    } else if (response.statusCode == 409) {
      return true; // Phone number already exists
    } else {
      throw Exception('Failed to validate phone number');
    }
  }
}
