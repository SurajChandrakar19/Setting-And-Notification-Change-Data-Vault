import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import '../services/host_service.dart';
import '../services/token_service.dart';

class ResumeService {
  static final String baseUrl = HostService.baseUrl;

  /// Downloads and opens a candidate's resume
  static Future<void> downloadAndOpenResume(int candidateId) async {
    final token = await TokenService.getValidAccessToken();
    if (token == null) {
      throw Exception('No access token found. Please login again.');
    }

    final url = Uri.parse('$baseUrl/candidate/$candidateId/resume/download');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final contentDisposition = response.headers['content-disposition'];
      final fileName =
          _extractFileName(contentDisposition ?? '') ??
          'resume_$candidateId.pdf';

      final bytes = response.bodyBytes;

      if (kIsWeb) {
        // ✅ Web download
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // ✅ Mobile/Desktop
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/$fileName';
        final file = io.File(filePath);
        await file.writeAsBytes(bytes);

        await OpenFilex.open(file.path);
      }
    } else {
      throw Exception(
        'Failed to download resume: ${response.statusCode}, ${response.body}',
      );
    }
  }

  /// Extracts filename from response header
  static String? _extractFileName(String contentDisposition) {
    final regex = RegExp(r'filename="?(.+)"?');
    final match = regex.firstMatch(contentDisposition);
    return match?.group(1);
  }

  /// Fallback temp directory
  static Future<io.Directory> getTemporaryDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
}
