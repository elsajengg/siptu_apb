import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );
  static String? _token;
  static Map<String, dynamic>? currentUser;

  static Map<String, String> get _authHeaders => {
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ──────────────────────────────────────────
  // AUTH
  // ──────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'] as String?;
        currentUser = Map<String, dynamic>.from(data['user'] as Map);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    if (_token == null) return {'success': true};
    try {
      await http.post(Uri.parse('$baseUrl/logout'), headers: _authHeaders);
    } catch (_) {}
    _token = null;
    currentUser = null;
    return {'success': true};
  }

  // ──────────────────────────────────────────
  // ROOMS
  // ──────────────────────────────────────────

  static Future<Map<String, dynamic>> getRooms() async {
    return _get('/rooms');
  }

  // ──────────────────────────────────────────
  // FACILITIES
  // ──────────────────────────────────────────

  static Future<Map<String, dynamic>> getFacilities({int? roomId}) async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }

    try {
      final uri = Uri.parse('$baseUrl/facilities').replace(
        queryParameters: roomId != null ? {'room_id': roomId.toString()} : null,
      );
      final response = await http.get(uri, headers: _authHeaders);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil data fasilitas',
      };
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ──────────────────────────────────────────
  // REPORTS
  // ──────────────────────────────────────────

  static Future<Map<String, dynamic>> createReport({
    required int facilityId,
    required String title,
    required String description,
    required String location,
    required List<XFile> photos,
  }) async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }

    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/reports'))
            ..headers.addAll(_authHeaders)
            ..fields['facility_id'] = facilityId.toString()
            ..fields['title'] = title
            ..fields['description'] = description
            ..fields['location'] = location;

      for (final photo in photos) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photos[]',
            await photo.readAsBytes(),
            filename: photo.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      }

      final errors = data['errors'];
      final validationMessage = errors is Map && errors.isNotEmpty
          ? (errors.values.first as List).first.toString()
          : null;

      return {
        'success': false,
        'message':
            validationMessage ?? data['message'] ?? 'Laporan gagal dikirim',
      };
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> getReports({
    bool feed = false,
    String? status,
  }) async {
    final path = feed ? '/reports/feed' : '/reports';
    final query = status == null ? '' : '?status=$status';
    return _getPaginated('$path$query');
  }

  static Future<Map<String, dynamic>> toggleLike(int reportId) async {
    return _postJson('/reports/$reportId/like', {});
  }

  // ──────────────────────────────────────────
  // STAFF
  // ──────────────────────────────────────────

  static Future<Map<String, dynamic>> getStaff() async {
    return _get('/staff');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final result = await _get('/user');
    if (result['success'] == true) {
      currentUser = Map<String, dynamic>.from(result['data'] as Map);
    }
    return result;
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    final result = await _patchJson('/user', {'name': name, 'email': email});
    if (result['success'] == true) {
      currentUser = Map<String, dynamic>.from(result['data'] as Map);
    }
    return result;
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String password,
  }) {
    return _patchJson('/user/password', {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': password,
    });
  }

  static Future<Map<String, dynamic>> createStaff({
    required String name,
    required String email,
    required String nip,
    required String password,
  }) {
    return _postJson('/staff', {
      'name': name,
      'email': email,
      'nip': nip.isEmpty ? null : nip,
      'password': password,
    }, expectedStatus: 201);
  }

  static Future<Map<String, dynamic>> updateStaff({
    required int id,
    required String name,
    required String email,
    required String nip,
    String? password,
  }) {
    return _patchJson('/staff/$id', {
      'name': name,
      'email': email,
      'nip': nip.isEmpty ? null : nip,
      if (password != null && password.isNotEmpty) 'password': password,
    });
  }

  static Future<Map<String, dynamic>> deleteStaff(int id) async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/staff/$id'),
        headers: _authHeaders,
      );
      return _decodeResponse(response);
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ──────────────────────────────────────────
  // ASSIGNMENTS
  // ──────────────────────────────────────────

  static Future<Map<String, dynamic>> assignReport({
    required int reportId,
    required int staffId,
    String? notes,
    DateTime? deadline,
  }) async {
    return _postJson('/reports/$reportId/assign', {
      'staff_id': staffId,
      if (notes != null && notes.trim().isNotEmpty) 'admin_notes': notes.trim(),
      if (deadline != null) 'deadline_at': deadline.toIso8601String(),
    }, expectedStatus: 201);
  }

  static Future<Map<String, dynamic>> rejectReport({
    required int reportId,
    required String reason,
  }) async {
    return _postJson('/reports/$reportId/reject', {'reason': reason});
  }

  static Future<Map<String, dynamic>> toggleReportLike(int reportId) {
    return _postJson('/reports/$reportId/like', {});
  }

  static Future<Map<String, dynamic>> submitReportFeedback({
    required int reportId,
    required int rating,
    required String notes,
  }) {
    return _postJson('/reports/$reportId/feedback', {
      'rating': rating,
      'feedback_notes': notes,
    });
  }

  // ──────────────────────────────────────────
  // TASKS
  // ──────────────────────────────────────────

  static Future<Map<String, dynamic>> getTasks({String? status}) async {
    final query = status == null ? '' : '?status=$status';
    return _getPaginated('/tasks$query');
  }

  static Future<Map<String, dynamic>> updateTask({
    required int taskId,
    required String status,
    required String notes,
    required List<XFile> photos,
  }) async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }

    try {
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('$baseUrl/tasks/$taskId/updates'),
            )
            ..headers.addAll(_authHeaders)
            ..fields['status'] = status
            ..fields['notes'] = notes;

      for (final photo in photos) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photos[]',
            await photo.readAsBytes(),
            filename: photo.name,
          ),
        );
      }

      final response = await http.Response.fromStream(await request.send());
      return _decodeResponse(response, expectedStatus: 201);
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ──────────────────────────────────────────
  // NOTIFICATIONS
  // ──────────────────────────────────────────

  static Future<Map<String, dynamic>> getNotifications() async {
    return _get('/notifications');
  }

  static Future<Map<String, dynamic>> markNotificationRead(String id) async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: _authHeaders,
      );
      return _decodeResponse(response);
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsRead() async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: _authHeaders,
      );
      return _decodeResponse(response);
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ──────────────────────────────────────────
  // DEVICES (Firebase)
  // ──────────────────────────────────────────

  static Future<Map<String, dynamic>> registerDevice({
    required String token,
    required String platform,
  }) async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devices'),
        headers: {..._authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'platform': platform}),
      );
      final data = jsonDecode(response.body);

      return response.statusCode == 200
          ? {'success': true, 'data': data['data']}
          : {
              'success': false,
              'message': data['message'] ?? 'Token Firebase gagal disimpan',
            };
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> sendTestNotification() async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/test'),
        headers: _authHeaders,
      );
      final data = jsonDecode(response.body);

      return response.statusCode == 200
          ? {'success': true, 'message': data['message']}
          : {
              'success': false,
              'message': data['message'] ?? 'Notifikasi uji gagal dikirim',
            };
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ──────────────────────────────────────────
  // MEDIA HELPER
  // ──────────────────────────────────────────

  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final apiUri = Uri.parse(baseUrl);
    return '${apiUri.scheme}://${apiUri.authority}/storage/$path';
  }

  // ──────────────────────────────────────────
  // PRIVATE HELPERS
  // ──────────────────────────────────────────

  static Future<Map<String, dynamic>> _get(String path) async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _authHeaders,
      );
      return _decodeResponse(response);
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> _getPaginated(String path) async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _authHeaders,
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': body['data'] ?? []};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Permintaan gagal',
      };
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload, {
    int expectedStatus = 200,
  }) async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: {..._authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return _decodeResponse(response, expectedStatus: expectedStatus);
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> _patchJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    if (_token == null) {
      return {'success': false, 'message': 'Sesi login tidak ditemukan'};
    }
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$path'),
        headers: {..._authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return _decodeResponse(response);
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Map<String, dynamic> _decodeResponse(
    http.Response response, {
    int expectedStatus = 200,
  }) {
    final data = jsonDecode(response.body);
    if (response.statusCode == expectedStatus) {
      return {'success': true, 'data': data['data'] ?? data};
    }

    final errors = data['errors'];
    final validationMessage = errors is Map && errors.isNotEmpty
        ? (errors.values.first as List).first.toString()
        : null;
    return {
      'success': false,
      'message': validationMessage ?? data['message'] ?? 'Permintaan gagal',
    };
  }
}
