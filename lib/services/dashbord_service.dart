import 'dart:convert';
import 'package:headsup_ats/models/yearly_monthly_model.dart';
import 'package:http/http.dart' as http;
import '../models/dashbord_summary_model.dart';
import '../services/host_service.dart';
import '../services/token_service.dart';

class DashboardSummaryService {
  static const String baseUrl = HostService.baseUrl;

  static Future<SimpleAdminDashboardSummary?> fetchSimpleAdminSummary() async {
    final token = await TokenService.getValidAccessToken();
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

  static Future<SimpleAdminDashboardSummary?> fetchSimpleUserSummary() async {
    final token = await TokenService.getValidAccessToken();
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

  static Future<SimpleAdminDashboardSummary?>
  fetchSimpleAdminUserSummary() async {
    final token = await TokenService.getValidAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/admin-user-summary'),
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

class ReportService {
  static const String baseUrl = HostService.baseUrl;
  Future<YearlyStatsModel?> fetchYearlyStats({
    required String userId,
    required String year,
  }) async {
    final token = await TokenService.getValidAccessToken();
    final url = Uri.parse(
      '$baseUrl/user-report/year?userId=$userId&year=$year',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return YearlyStatsModel.fromJson(json.decode(response.body));
    } else {
      print('Failed to load yearly stats: ${response.body}');
      return null;
    }
  }

  Future<YearlyStatsModel?> fetchMonthlyStats({
    required String userId,
    required String year,
    required String month,
  }) async {
    final token = await TokenService.getValidAccessToken();
    final url = Uri.parse(
      '$baseUrl/user-report/monthly?userId=$userId&year=$year&month=$month',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return YearlyStatsModel.fromJson(json.decode(response.body));
    } else {
      print('Failed to load yearly stats: ${response.body}');
      return null;
    }
  }
}
