import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../services/host_service.dart';

class ResumeService {
  static final String baseUrl = HostService.baseUrl;

  // ResumeService({required this.baseUrl});

  static Future<void> downloadAndOpenResume({
    required int candidateId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/candidate/$candidateId/resume/download');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final contentDisposition = response.headers['content-disposition'];
      final fileName =
          _extractFileName(contentDisposition ?? '') ??
          'resume_${candidateId}.pdf';

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
      throw Exception('Failed to download resume: ${response.statusCode}');
    }
  }

  static String? _extractFileName(String contentDisposition) {
    final regex = RegExp(r'filename="?(.+)"?');
    final match = regex.firstMatch(contentDisposition);
    return match != null ? match.group(1) : null;
  }

  static Future<io.Directory> getTemporaryDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
}
