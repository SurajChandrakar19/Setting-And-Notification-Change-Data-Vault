import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:headsup_ats/models/db_candiate_status_model.dart';
import '../models/db_vault_model.dart';
import 'host_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/db_candidate_model.dart';

class CadidateDBService {
  static const String baseUrl = HostService.baseUrl;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/api'));

  Future<List<CandidateDB>> getCandidates() async {
    final response = await _dio.get('/candidates');
    return (response.data as List)
        .map((json) => CandidateDB.fromJson(json))
        .toList();
  }

  Future<void> createCandidate(CandidateDB candidate) async {
    await _dio.post('/candidates', data: candidate.toJson());
  }

  Future<void> updateCandidate(int id, CandidateDB candidate) async {
    await _dio.put('/candidates/$id', data: candidate.toJson());
  }

  // Future<void> importCandidates(List<CandidateDB> list) async {
  //   final jsonList = list.map((c) => c.toJson()).toList();
  //   await _dio.post('/candidates/import', data: jsonList);
  // }

  static Future<Map<String, dynamic>> importCandidates(
    List<CandidateDB> candidates,
    String token,
  ) async {
    final url = Uri.parse("$baseUrl/candidate-db/import");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(candidates.map((e) => e.toJson()).toList()),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return {
          'success': true,
          'inserted': result['inserted'],
          'skipped': result['skippedDuplicates'],
        };
      } else {
        return {
          'success': false,
          'message': "❌ Upload failed: ${response.reasonPhrase}",
        };
      }
    } catch (e) {
      return {'success': false, 'message': "❌ Failed to send data. Error: $e"};
    }
  }

  Future<List<CandidateModelConverter>> getAllCandidates(
    int userId,
    String accessToken,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/candidate-db/all'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData
          .map((json) => CandidateModelConverter.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to fetch candidates: ${response.body}");
    }
  }

  Future<List<CandidateModelConverter>> getAllUnlockedCandidates(
    int userId,
    String accessToken,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/candidate-db/unlocked'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData
          .map((json) => CandidateModelConverter.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to fetch candidates: ${response.body}");
    }
  }

  Future<List<CandidateModelConverter>> getAllLockedCandidates(
    int userId,
    String accessToken,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/candidate-db/locked'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData
          .map((json) => CandidateModelConverter.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to fetch candidates: ${response.body}");
    }
  }

  Future<void> addStatus(DBStatusDTO status, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(status.toJson()),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to add status: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error calling addStatus: $e');
    }
  }

  Future<bool> unlockCandidateById(String id, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/candidate-db/unlock/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to unlock candidate: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Unlock API error: $e');
      return false;
    }
  }
}
