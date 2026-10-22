import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app_wahana/config/api_config.dart';
import 'package:super_app_wahana/models/karyawan_model.dart';
import 'package:super_app_wahana/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<UserModel?> login(
    String username,
    String password,
    String deviceId,
  ) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'device_id': deviceId,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final user = UserModel.fromJson(data);
        await _saveUserData(user);
        return user;
      } else {
        throw Exception('Login failed: ${res.body}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Api Call Logout
        final res = await http.post(
          Uri.parse(ApiConfig.logoutUrl),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (res.statusCode != 200) {
          throw Exception('Logout failed: ${res.body}');
        }
      }
    } catch (e) {
      throw Exception('Error during logout: $e');
    }

    // Clear Local Data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    return true;
  }

  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final expiresAtStr = prefs.getString('token_expires_at');

    if (token == null || expiresAtStr == null) return false;

    final expiresAt = DateTime.parse(expiresAtStr);
    return DateTime.now().isBefore(expiresAt);
  }

  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token);
    await prefs.setInt('role', user.role);
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    await prefs.setString('nik', user.nik);
    await prefs.setString('token_expires_at', user.tokenExpiresAt);
  }

  Future<void> _saveKaryawanData(KaryawanModel karyawan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emp_id', karyawan.empId);
    await prefs.setString('emp_name', karyawan.empName);
    await prefs.setString('user_id_hris', karyawan.userIdHris);
    await prefs.setString('company', karyawan.company);
    await prefs.setString('position_title', karyawan.positionTitle);
    await prefs.setString('dept', karyawan.dept);
    await prefs.setString('supervisor_name', karyawan.supervisorName);
    await prefs.setString('email', karyawan.email);
    await prefs.setString('remarks', karyawan.remarks);
    await prefs.setString('created_at', karyawan.createdAt.toString());
    await prefs.setString('updated_at', karyawan.updatedAt.toString());
  }

  Future<KaryawanModel?> getKaryawan() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/karyawan/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final karyawan = KaryawanModel.fromJson(data);
        await _saveKaryawanData(karyawan); // Simpan locally
        return karyawan;
      } else {
        throw Exception('Failed to fetch karyawan: ${res.body}');
      }
    } catch (e) {
      throw Exception('Error fetching karyawan: $e');
    }
  }

  static Future<String?> getDeptFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('dept');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<int?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('role');
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  static Future<String?> getNik() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nik');
  }
}
