import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/app_user.dart';
import '../models/group.dart';
import '../models/month_entry.dart';
import '../models/sofa_loan.dart';
import '../models/sofa_loan_entry.dart';
import '../models/village_option.dart';

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

  Future<({String token, AppUser user})> login(String userId, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'user_id': userId,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    final user = AppUser(
      userId: data['user_id'] as String,
      name: data['name'] as String,
      role: data['role'] as String,
    );
    return (token: data['token'] as String, user: user);
  }

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

  Future<Group> createGroup({
    required String name,
    required String code,
    required String villageName,
    String? meetingDay,
  }) async {
    final response = await _dio.post('/groups', data: {
      'name': name,
      'code': code,
      'village_name': villageName,
      if (meetingDay != null) 'meeting_day': meetingDay,
    });
    return Group.fromJson(response.data as Map<String, dynamic>);
  }

  // -- Villages --

  Future<List<VillageOption>> fetchVillages() async {
    final response = await _dio.get('/villages');
    return (response.data as List)
        .map((v) => VillageOption.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  Future<void> createVillage(String name, {String? abbreviation}) async {
    await _dio.post('/villages', data: {
      'name': name,
      if (abbreviation != null && abbreviation.isNotEmpty)
        'abbreviation': abbreviation,
    });
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

  // -- SOFA Loans --

  Future<List<SofaLoan>> fetchSofaLoans(int groupId) async {
    final response = await _dio.get('/groups/$groupId/sofa-loans');
    return (response.data as List)
        .map((json) => SofaLoan.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SofaLoan> createSofaLoan(
      int groupId, double principalAmount, String disbursedDate) async {
    final response = await _dio.post('/groups/$groupId/sofa-loans', data: {
      'principal_amount': principalAmount,
      'disbursed_date': disbursedDate,
    });
    return SofaLoan.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SofaLoan> closeSofaLoan(int loanId) async {
    final response = await _dio.post('/sofa-loans/$loanId/close');
    return SofaLoan.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<SofaLoanEntry>> fetchSofaLoanEntries(int loanId) async {
    final response = await _dio.get('/sofa-loans/$loanId/entries');
    return (response.data as List)
        .map((json) => SofaLoanEntry.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // -- Reports --

  Future<DashboardSummary> fetchDashboard() async {
    final response = await _dio.get('/reports/dashboard');
    return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
