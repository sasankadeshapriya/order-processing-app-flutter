import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Add this line to import the 'jwt_decoder' package

class TokenManager {
  static const String _tokenKey = 'token';
  static int? empId;

  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> retrieveEmpId() async {
    final String? token = await TokenManager.getToken(); // Make sure TokenManager handles token securely
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token); // Now 'JwtDecoder' is defined
        TokenManager.empId = decodedToken['userId'] as int?;
      } catch (e) {
        print('Error decoding token: $e');
      }
    }
  }
}
