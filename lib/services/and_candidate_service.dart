import 'dart:io';

import '../models/company_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/company_id_name_model.dart';
import '../models/candidate_create_model.dart';
import '../models/create_candidate_response.dart';
import 'package:http_parser/http_parser.dart';
import '../models/create_candidate_with_resume.dart';
import 'package:mime/mime.dart'; // for lookupMimeType
import 'package:path/path.dart'; // for basename
import '../services/host_service.dart'; // Ensure you have this import for baseUrl

class AddCandidateService {
  static const String baseUrl = HostService.baseUrl;

  // this method help to get all Locality Name from the database
  static Future<List<String>> fetchLocalityNames(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/localities'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map<String>((json) => json['name'] as String).toList();
    } else {
      throw Exception('Failed to load locality names');
    }
  }

  // this method help to get all Job Role Categories Name from the database
  static Future<List<String>> fetchjobCategories(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jobs/job-categories'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map<String>((json) => json['name'] as String).toList();
    } else {
      throw Exception('Failed to load locality names');
    }
  }

  // Simulate database call for companies
  Future<List<Company>> getCompanies() async {
    // Replace this with your actual database call
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    // Return companies from your database
    return [
      Company(
        id: '1',
        name: 'Tech Solutions Pvt Ltd',
        address: 'The Skyline • Seoul Plaza Rd',
      ),
      Company(
        id: '2',
        name: 'Innovation Hub Corp',
        address: 'Tech Park • Whitefield',
      ),
      Company(
        id: '3',
        name: 'Digital Dynamics Ltd',
        address: 'Business Hub • Koramangala',
      ),
    ];
  }

  static Future<List<CompanyIdName>> fetchJobIdAndCompanyNames(
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/candidates/companies');

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

  // static Future<bool> createCandidate(
  //   CandidateCreateDTO candidate,
  //   String userId,
  //   File? _resumeFile,
  // ) async {
  //   final url = Uri.parse('$baseUrl/$userId/add-candidate');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(candidate.toJson()),
  //   );
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     return true;
  //   } else {
  //     print('Failed to create candidate: ${response.body}');
  //     return false;
  //   }
  // }

  // static Future<bool> createCandidate(
  //   CandidateCreateDTO candidate,
  //   String userId,
  //   File? resumeFile,
  // ) async {
  //   final url = Uri.parse(
  //     '$baseUrl/$userId/dashboard/add-candidates',
  //   ); // Endpoint expects ?userid= in body, not URL
  //   final request = http.MultipartRequest('POST', url)
  //     ..fields['userid'] = userId
  //     ..fields['candidate'] = json.encode(candidate.toJson());
  //   if (resumeFile != null) {
  //     request.files.add(
  //       await http.MultipartFile.fromPath('resume', resumeFile.path),
  //     );
  //   }
  //   try {
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return true;
  //     } else {
  //       print('Failed to create candidate: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error uploading candidate: $e');
  //     return false;
  //   }
  // }

  static Future<bool> createCandidate(
    CandidateCreateDTO candidate,
    String userId,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/candidate');

    // Create the POST request
    final request = http.Request('POST', url)
      ..headers['Authorization'] =
          'Bearer $token' // Include the Authorization header
      ..headers['Content-Type'] =
          'application/json' // Set Content-Type as JSON
      ..body = json.encode({
        'candidate': candidate.toJson(), // Add candidate data
      });

    try {
      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Check for successful status code (201 or 200)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Success
      } else {
        print('Failed: ${response.statusCode}, ${responseBody}');
        return false; // Failure
      }
    } catch (e) {
      print('Exception: $e');
      return false; // Exception occurred
    }
  }

  static Future<CandidateCreateResponse> createCandidateWithResume({
    required String name,
    required String role,
    required String location,
    required String qualification,
    required String experience,
    required int age,
    required bool isActiveCandidate,
    required String phone,
    required String email,
    required String interviewTime,
    required String interviewLocation,
    required String interviewNotes,
    required String interviewType,
    required int jobId,
    required String companyName,
    required String resumeFileName,
    required String resumeFileType,
    required String status,
    var resumeFile, // This will hold the resume file data (as Multipart)
    required String token,
  }) async {
    var uri = Uri.parse('$baseUrl/candidate/create-with-resume');

    var request = http.MultipartRequest('POST', uri);

    // Add Authorization header with Bearer token
    request.headers['Authorization'] = 'Bearer $token';

    // Add the form fields
    request.fields['name'] = name;
    request.fields['role'] = role;
    request.fields['location'] = location;
    request.fields['qualification'] = qualification;
    request.fields['experience'] = experience;
    request.fields['age'] = age.toString();
    request.fields['isActiveCandidate'] = isActiveCandidate.toString();
    request.fields['phone'] = phone;
    request.fields['email'] = email;
    request.fields['interviewTime'] = interviewTime;
    request.fields['interviewLocation'] = interviewLocation;
    request.fields['interviewNotes'] = interviewNotes;
    request.fields['interviewType'] = interviewType;
    request.fields['jobId'] = jobId.toString();
    request.fields['companyName'] = companyName;
    request.fields['status'] = status;

    // Add the resume file
    if (resumeFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'resumeFile', // The key of your file parameter
          resumeFile.path,
          filename: resumeFileName,
        ),
      );
    }

    try {
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData.body);
        return CandidateCreateResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to create candidate');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  // static Future<void> uploadCandidateWithResume({
  //   required CandidateCreateWithResumeDTO candidate,
  //   File? resumeFile, // Optional: if you want to upload a resume file
  //   required String jwtToken, // Optional if you use token auth
  // }) async {
  //   final uri = Uri.parse('$baseUrl/candidate/create-with-resume');
  //   final request = http.MultipartRequest('POST', uri);

  //   // Attach candidate JSON as string part
  //   final jsonCandidate = jsonEncode(candidate.toJson());
  //   request.fields['candidateData'] = jsonCandidate;

  //   Optional: attach resume file
  //   if (resumeFile != null) {
  //     final mimeType = lookupMimeType(resumeFile.path) ?? 'application/octet-stream';
  //     request.files.add(
  //       await http.MultipartFile.fromPath(
  //         'resumeFile',
  //         resumeFile.path,
  //         contentType: MediaType.parse(mimeType),
  //         filename: basename(resumeFile.path),
  //       ),
  //     );
  //   }

  //   // Add Authorization Header if required
  //   request.headers['Authorization'] = 'Bearer $jwtToken';
  //   // request.headers['Content-Type'] = 'multipart/form-data';

  //   final response = await request.send();
  //   final respStr = await response.stream.bytesToString();

  //   if (response.statusCode == 201) {
  //     print("Candidate created: $respStr");
  //   } else {
  //     print("Error (${response.statusCode}): $respStr");
  //     throw Exception("Failed to upload candidate");
  //   }
  // }

  static Future<String> uploadCandidateWithResume({
    required CandidateCreateWithResumeDTO candidate,
    File? resumeFile,
    required String jwtToken,
  }) async {
    final uri = Uri.parse('$baseUrl/candidate/create-with-resume');
    final request = http.MultipartRequest('POST', uri);

    // Candidate JSON data
    final jsonCandidate = jsonEncode(candidate.toJson());
    request.fields['candidateData'] = jsonCandidate;

    // Optional resume file
    if (resumeFile != null) {
      final mimeType =
          lookupMimeType(resumeFile.path) ?? 'application/octet-stream';
      request.files.add(
        await http.MultipartFile.fromPath(
          'resumeFile',
          resumeFile.path,
          contentType: MediaType.parse(mimeType),
          filename: basename(resumeFile.path),
        ),
      );
    }

    // Add JWT token
    request.headers['Authorization'] = 'Bearer $jwtToken';

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        return "Candidate created successfully";
      } else {
        // Attempt to parse backend error message
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

  // Method to check if a phone number is already taken
  static Future<bool> isPhoneNumberTaken(String phone, String token) async {
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
