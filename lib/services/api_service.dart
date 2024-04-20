import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  static const String baseUrl = 'https://api.gsutil.xyz';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employee/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Login successful
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String email = responseData['email'];
      return {'success': true, 'email': email};
    } else {
      // Login failed
      return {'success': false, 'error': 'Login failed'};
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(String email, int otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employee/verify-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      // OTP verification successful
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String token = responseData['token'];
      return {'success': true, 'token': token};
    } else {
      // OTP verification failed
      return {'success': false, 'error': 'OTP verification failed'};
    }
  }

  static Future<Map<String, dynamic>> sendOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employee/forgot-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String userEmail = responseData['email'];
      return {'success': true, 'email': userEmail};
    } else {
      return {'success': false, 'error': 'Failed to send OTP'};
    }
  }

  static Future<Map<String, dynamic>> verifyNewPasswordOTP(
      String email, int otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employee/password-change-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      // OTP verification successful
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String email = responseData['email'];
      return {'success': true, 'email': email};
    } else {
      // OTP verification failed
      return {'success': false, 'error': 'OTP verification failed'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(
      String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employee/password-change'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'error': 'Password change failed'};
    }
  }
}
