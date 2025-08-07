import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/host_service.dart';
// import 'dart:html' as html;

class ReachedCandidateService {
  static const String baseUrl = HostService.baseUrl;

  static Future<List<Map<String, dynamic>>> fetchReachedCandidates(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reached-candidates'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        // Convert List<dynamic> to List<Map<String, dynamic>>
        final List<Map<String, dynamic>> result = jsonList
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        return result;
      } else if (response.statusCode == 404) {
        throw Exception('Reached candidates not found');
      } else {
        throw Exception(
          'Failed to load reached candidates. Status code: ${response.statusCode}',
        );
      }
    } catch (error) {
      // Optional: you can log the error or send it to an error tracking system
      throw Exception('Error fetching reached candidates: $error');
    }
  }

  // static Future<void> downloadReachedCandidatesCSV(String token) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/applications/export'),
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
  //       final filePath = '${directory.path}/reached_candidates.csv';
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
  //   // Encode CSV to bytes
  //   final bytes = utf8.encode(csvContent);
  //   final uint8List = Uint8List.fromList(bytes);

  //   // Convert to JS Uint8Array
  //   final jsUint8Array = uint8List.toJS;

  //   // Create JSArray<JSAny> and add our binary data
  //   final blobParts = JSArray<JSAny>();
  //   blobParts.add(jsUint8Array as JSAny);

  //   // Construct Blob
  //   final blob = web.Blob(
  //     blobParts,
  //     web.BlobPropertyBag(type: 'text/csv'.toString()),
  //   );

  //   // Create object URL for blob
  //   final url = web.URL.createObjectURL(blob);

  //   // Create anchor and configure it
  //   final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  //   anchor.href = url;
  //   anchor.download = fileName;
  //   anchor.style.display = 'none';

  //   // Trigger download
  //   web.document.body!.appendChild(anchor);
  //   anchor.click();
  //   anchor.remove();

  //   // Clean up
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

  // }
}

class CandidateTrack {
  static const String baseUrl = 'http://localhost:8080/v1/auth';

  static Future<bool> updateStatus(
    String candidateId,
    String newStatus,
    String userId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$userId/applications/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'candidateId': int.parse(candidateId),
          'userId': int.parse(userId),
          'status': newStatus.toUpperCase(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Optionally log error
        return false;
      }
    } catch (e) {
      // Handle exception (e.g., network issues)
      rethrow;
    }
  }
}

class CandidateTrackService {
  static const String baseUrl = HostService.baseUrl;

  static Future<bool> updateStatus({
    required int candidateId,
    required int userId,
    required String status,
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/applications');

    final body = jsonEncode({
      'candidateId': candidateId,
      'userId': userId,
      'status': status.toUpperCase(),
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Exception during updateStatus: $e');
      return false;
    }
  }
}
