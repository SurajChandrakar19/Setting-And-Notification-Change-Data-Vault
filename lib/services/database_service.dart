import '../models/company_model.dart';
import '../models/localities_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/host_service.dart';

class DatabaseService {
  static const String baseUrl = HostService.baseUrl;
}
