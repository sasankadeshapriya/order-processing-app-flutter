import 'package:jwt_decoder/jwt_decoder.dart'; // Add this line to import the 'jwt_decoder' package
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  // static const String _tokenKey = 'token';
  // static int? empId;
  //
  // static Future<void> saveToken(String token) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(_tokenKey, token);
  // }

  static const String _tokenKey = 'token';
  static const String _empIdKey = 'empId';
  static int? empId;

  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!JwtDecoder.isExpired(token)) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print(
            'Decoded Token: $decodedToken'); // Print the decoded token to check its contents
        empId = decodedToken['userId']
            as int?; // Change 'userId' to the correct key if necessary
        print('Extracted empId: $empId'); // Print the extracted empId
        if (empId != null) {
          await prefs.setInt(_empIdKey, empId!);
          print(
              'empId saved to SharedPreferences'); // Confirm saving to SharedPreferences
        }
      } catch (e) {
        print('Error decoding token: $e');
      }
    }

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

  // static Future<void> retrieveEmpId() async {
  //   final String? token = await TokenManager
  //       .getToken(); // Make sure TokenManager handles token securely
  //   if (token != null) {
  //     try {
  //       Map<String, dynamic> decodedToken =
  //           JwtDecoder.decode(token); // Now 'JwtDecoder' is defined
  //       TokenManager.empId = decodedToken['userId'] as int?;
  //     } catch (e) {
  //       print('Error decoding token: $e');
  //     }
  //   }
  // }

  static Future<void> retrieveEmpId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    empId = prefs.getInt(_empIdKey);
    print(
        'Retrieved empId from SharedPreferences: $empId'); // Print the retrieved empId
  }
}
