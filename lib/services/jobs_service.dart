import 'dart:convert';
import 'dart:io';
// Only for mobile/desktop
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';

// Remove these if not used:
import '../models/job_model_create.dart';
import '../services/host_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

// import 'dart:html' as html;

class JobService {
  static const String baseUrl = HostService.baseUrl; // Update to your serve

  static Future<List<Job>> fetchJobsByUserId(String token) async {
    try {
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

  static Future<void> createJob(Job job, String token) async {
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

  static Future<void> updateJob(Job job) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${job.userId}/jobs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(job.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update job');
    }
  }

  static Future<void> deleteJob(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/jobs/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete job');
    }
  }

  // static Future<void> downloadJobsCSV(String token) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/jobs/export'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     if (kIsWeb) {
  //       // Web download logic
  //       downloadCsvInWeb(response.body, 'reached_candidates.csv');
  //     } else {
  //       // Mobile/Desktop logic
  //       final directory = await getApplicationDocumentsDirectory();
  //       final filePath = '${directory.path}/jobs.csv';
  //       final file = File(filePath);
  //       await file.writeAsBytes(response.bodyBytes);
  //       print('CSV downloaded at $filePath');
  //     }
  //   } else {
  //     throw Exception(
  //       'Failed to download CSV. Status code: ${response.statusCode}',
  //     );
  //   }
  // }

  // static void downloadCsvInWeb(String csvContent, String fileName) {
  //   // Convert to bytes
  //   final bytes = utf8.encode(csvContent);
  //   final uint8List = Uint8List.fromList(bytes);

  //   // Convert to JS Uint8Array
  //   final jsUint8Array = uint8List.toJS;

  //   // Create JSArray for Blob constructor
  //   final blobParts = JSArray<JSAny>();
  //   blobParts.add(jsUint8Array as JSAny);

  //   // Create the Blob
  //   final blob = web.Blob(
  //     blobParts,
  //     web.BlobPropertyBag(type: 'text/csv'.toJS),
  //   );

  //   // Generate download URL
  //   final url = web.URL.createObjectURL(blob);

  //   // Create anchor element
  //   final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  //   anchor.href = url;
  //   anchor.download = fileName.toJS; // ✅ must be JSString
  //   anchor.style.display = 'none'.toJS; // ✅ must be JSString

  //   // Trigger download
  //   web.document.body!.appendChild(anchor);
  //   anchor.click();
  //   anchor.remove();

  //   // Cleanup
  //   web.URL.revokeObjectURL(url);
  // }

  // static void downloadCsvInWeb(String csvContent, String fileName) {
  //   // Convert to bytes
  //   final bytes = utf8.encode(csvContent);
  //   final uint8List = Uint8List.fromList(bytes);

  //   // Convert to JS Uint8Array
  //   final jsUint8Array = uint8List.toJS;

  //   // Create JSArray for Blob constructor
  //   final blobParts = JSArray<JSAny>();
  //   blobParts.add(jsUint8Array as JSAny);

  //   // ✅ Use .toJS only for BlobPropertyBag
  //   final blob = web.Blob(
  //     blobParts,
  //     web.BlobPropertyBag(type: 'text/csv'.toJS),
  //   );

  //   // Create download URL
  //   final url = web.URL.createObjectURL(blob);

  //   // Create anchor element
  //   final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  //   anchor.href = url;
  //   anchor.download = fileName; // ✅ Use regular Dart string
  //   anchor.style.display = 'none'; // ✅ Use regular Dart string

  //   // Trigger download
  //   web.document.body!.appendChild(anchor);
  //   anchor.click();
  //   anchor.remove();

  //   // Cleanup
  //   web.URL.revokeObjectURL(url);
  // }

  // static void downloadCsvInWeb(String csvData, String filename) {
  //   final bytes = utf8.encode(csvData);
  //   final blob = html.Blob([bytes]);
  //   final url = html.Url.createObjectUrlFromBlob(blob);
  //   final anchor = html.AnchorElement(href: url)
  //     ..setAttribute("download", filename)
  //     ..click();
  //   html.Url.revokeObjectUrl(url);
  // }

  // static Future<bool> createJob(JobModel job) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/create'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(job.toJson()),
  //   );

  //   if (response.statusCode == 201) {
  //     return true;
  //   } else {
  //     print('Failed to post job: ${response.body}');
  //     return false;
  //   }
  // }

  static Future<void> downloadJobsCSV(String jwtToken) async {
    final url = Uri.parse('$baseUrl/jobs/export');
    final fileName = 'jobs_${DateTime.now().millisecondsSinceEpoch}.csv';

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $jwtToken', 'Accept': 'text/csv'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to download CSV. Status: ${response.statusCode}');
    }

    final csvBytes = response.bodyBytes;

    if (kIsWeb) {
      // ✅ Web-specific CSV download logic using universal_html
      final blob = html.Blob([csvBytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      return;
    }

    if (!(Platform.isAndroid || Platform.isIOS)) {
      throw UnsupportedError(
        'CSV download supported only on Android, iOS, or Web.',
      );
    }

    // ✅ Mobile: Write file and open
    if (Platform.isAndroid) {
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        throw Exception('Storage permission denied.');
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(csvBytes);

    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('Failed to open file: ${result.message}');
    }
  }
}
