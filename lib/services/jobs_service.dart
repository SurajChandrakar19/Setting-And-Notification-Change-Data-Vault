import 'dart:convert';
import 'dart:io';
// Only for mobile/desktop
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';

// Remove these if not used:
import '../models/job_model_create.dart';
import '../services/host_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import '../services/token_service.dart';

// import 'dart:html' as html;

class JobService {
  static const String baseUrl = HostService.baseUrl; // Update to your serve

  // using
  static Future<List<Job>> fetchJobsByUserId() async {
    try {
      final token = await TokenService.getValidAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        // return <List<Job>>.fromJson(jsonData);
        return jsonData.map((e) => Job.fromJson(e)).toList();
      } else {
        throw Exception('Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('JobService fetch error: $e');
      rethrow;
    }
  }

  // using
  static Future<void> createJob(Job job) async {
    final token = await TokenService.getValidAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/jobs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(job.toJsonCreate()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create job');
    }
  }

  // using
  static Future<void> deleteJob(int id) async {
    final token = await TokenService.getValidAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/jobs/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete job');
    }
  }

  static Future<void> downloadJobsCSV() async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) {
      throw Exception('No access token found. Please login again.');
    }

    final url = Uri.parse('$baseUrl/jobs/export');
    final fileName = 'jobs_${DateTime.now().millisecondsSinceEpoch}.csv';

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'text/csv'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download CSV. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final csvBytes = response.bodyBytes;

    // ✅ Web
    if (kIsWeb) {
      final blob = html.Blob([csvBytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      return;
    }

    // ✅ Desktop & Mobile (Android/iOS/macOS/Windows/Linux)
    if (!(Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux)) {
      throw UnsupportedError(
        'CSV download supported only on Android, iOS, Web, or Desktop.',
      );
    }

    // ✅ Request storage permission on Android
    if (Platform.isAndroid) {
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        throw Exception('Storage permission denied.');
      }
    }

    // ✅ Save file in app documents directory
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(csvBytes);

    // ✅ Open file with default app
    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('Failed to open file: ${result.message}');
    }
  }
}
