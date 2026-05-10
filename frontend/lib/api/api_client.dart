import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/group.dart';
import '../models/month_entry.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({String baseUrl = 'http://localhost:8000'})
      : _dio = Dio(BaseOptions(
          baseUrl: '$baseUrl/api/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        )),
        _storage = const FlutterSecureStorage() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  // -- Auth --

  Future<void> saveToken(String token) =>
      _storage.write(key: 'jwt_token', value: token);

  Future<void> clearToken() => _storage.delete(key: 'jwt_token');

  Future<bool> hasToken() async =>
      (await _storage.read(key: 'jwt_token')) != null;

  // -- Groups --

  Future<List<Group>> fetchGroups() async {
    final response = await _dio.get('/groups');
    return (response.data as List)
        .map((json) => Group.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // -- Month Entries --

  Future<Map<String, dynamic>> createEntry(Map<String, dynamic> payload) async {
    final response = await _dio.post('/month-entries', data: payload);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateEntry(
      int entryId, Map<String, dynamic> payload) async {
    final response =
        await _dio.patch('/month-entries/$entryId', data: payload);
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchEntries() async {
    final response = await _dio.get('/month-entries');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  // -- Reports --

  Future<DashboardSummary> fetchDashboard() async {
    final response = await _dio.get('/reports/dashboard');
    return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
