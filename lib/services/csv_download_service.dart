import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import '../services/host_service.dart';
import '../services/token_service.dart';
import '../services/mobile_download_service.dart';

class CSVDownloadService {
  static const String baseUrl = HostService.baseUrl;

  // using
  /// Downloads Jobs CSV from server or generates sample data
  static Future<void> downloadJobsCSV({bool useSampleData = false}) async {
    try {
      final fileName = MobileDownloadService.getSafeFileName(
        'jobs_${DateTime.now().millisecondsSinceEpoch}.csv',
      );

      Uint8List csvBytes;

      if (useSampleData) {
        // Sample Jobs CSV data
        const csvContent = '''Job ID,Job Title,Department,Location,Posted Date
101,Software Engineer,Engineering,New York,2025-08-20
102,Product Manager,Product,San Francisco,2025-08-21
103,Data Analyst,Analytics,Chicago,2025-08-22''';
        csvBytes = Uint8List.fromList(utf8.encode(csvContent));
      } else {
        // Get access token and fetch from server
        final token = await TokenService.getValidAccessToken();
        if (token == null) throw Exception("No valid token available");

        final url = Uri.parse('$baseUrl/jobs/export');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'text/csv',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Failed to download Jobs CSV. Status: ${response.statusCode}\n'
            'Response: ${response.body}',
          );
        }
        csvBytes = response.bodyBytes;
      }

      await _handleDownload(csvBytes, fileName);
    } catch (e) {
      debugPrint('Error in downloadJobsCSV: $e');
      rethrow;
    }
  }

  // using
  /// Downloads Applications CSV from server or generates sample data
  static Future<void> downloadApplicationsCSV({
    bool useSampleData = false,
  }) async {
    try {
      final fileName = MobileDownloadService.getSafeFileName(
        'applications_${DateTime.now().millisecondsSinceEpoch}.csv',
      );

      Uint8List csvBytes;

      if (useSampleData) {
        // Sample Applications CSV data
        const csvContent = '''Application ID,Job ID,Candidate Name,Email,Status
201,101,John Doe,john.doe@example.com,Pending
202,102,Jane Smith,jane.smith@example.com,Reviewed
203,103,Michael Johnson,michael.johnson@example.com,Selected''';
        csvBytes = Uint8List.fromList(utf8.encode(csvContent));
      } else {
        // Get access token and fetch from server
        final token = await TokenService.getValidAccessToken();
        if (token == null) throw Exception("No valid token available");

        final url = Uri.parse('$baseUrl/applications/export');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'text/csv',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Failed to download Applications CSV. Status: ${response.statusCode}\n'
            'Response: ${response.body}',
          );
        }
        csvBytes = response.bodyBytes;
      }

      await _handleDownload(csvBytes, fileName);
    } catch (e) {
      debugPrint('Error in downloadApplicationsCSV: $e');
      rethrow;
    }
  }

  // using
  /// Downloads DataVault (Candidates) CSV from server or generates sample data
  static Future<void> downloadDataVaultCSV({bool useSampleData = false}) async {
    try {
      final fileName = MobileDownloadService.getSafeFileName(
        'candidates_template_${DateTime.now().millisecondsSinceEpoch}.csv',
      );

      Uint8List csvBytes;

      if (useSampleData) {
        // Sample DataVault CSV data
        const csvContent = '''Candidate ID,Name,Email,Phone,Resume
301,Alex Brown,alex.brown@example.com,1234567890,resume_alex.pdf
302,Linda Green,linda.green@example.com,9876543210,resume_linda.pdf
303,Chris White,chris.white@example.com,5556667777,resume_chris.pdf''';
        csvBytes = Uint8List.fromList(utf8.encode(csvContent));
      } else {
        // Get access token and fetch from server
        final token = await TokenService.getValidAccessToken();
        if (token == null) throw Exception("No valid token available");

        final url = Uri.parse('$baseUrl/candidates/export');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'text/csv',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Failed to download DataVault CSV. Status: ${response.statusCode}\n'
            'Response: ${response.body}',
          );
        }
        csvBytes = response.bodyBytes;
      }

      await _handleDownload(csvBytes, fileName);
    } catch (e) {
      debugPrint('Error in downloadDataVaultCSV: $e');
      rethrow;
    }
  }

  // using
  /// Handles the platform-specific download logic
  static Future<void> _handleDownload(
    Uint8List csvBytes,
    String fileName,
  ) async {
    if (kIsWeb) {
      // Web-specific CSV download logic using universal_html
      final blob = html.Blob([csvBytes], 'text/csv');
      final downloadUrl = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: downloadUrl)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(downloadUrl);
      return;
    }

    if (Platform.isAndroid) {
      // Android: Use MobileDownloadService with proper permissions (without opening)
      final filePath = await MobileDownloadService.downloadFileToDownloads(
        bytes: csvBytes,
        fileName: fileName,
      );
      debugPrint('CSV file successfully downloaded to: $filePath');
    } else if (Platform.isIOS) {
      // iOS: Use application documents directory (without opening)
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(csvBytes);
      debugPrint('CSV file successfully downloaded to: $filePath');
    } else {
      throw UnsupportedError(
        'CSV download supported only on Android, iOS, or Web.',
      );
    }
  }
}
