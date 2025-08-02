import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashbord_summary_model.dart';
import '../services/host_service.dart';

class DashboardSummaryService {
  static const String baseUrl = HostService.baseUrl;

  static Future<SimpleAdminDashboardSummary?> fetchSimpleAdminSummary(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/admin-summary'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return SimpleAdminDashboardSummary.fromJson(jsonDecode(response.body));
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }

  static Future<SimpleAdminDashboardSummary?> fetchSimpleUserSummary(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/user-summary'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return SimpleAdminDashboardSummary.fromJson(jsonDecode(response.body));
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }
}
