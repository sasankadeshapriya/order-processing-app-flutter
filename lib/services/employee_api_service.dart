import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:order_processing_app/models/employee_model.dart';

class EmployeeService {
  static const String baseUrl = 'https://api.gsutil.xyz';
  static final Map<int, EmployeeModel> _cache = {};

  // Fetch employee details
  static Future<EmployeeModel> getEmployeeDetails(int id) async {
    print('Fetching details for employee with ID: $id');

    final url = '$baseUrl/employee/$id/details';
    print('Requesting data from URL: $url');
    final response = await http.get(Uri.parse(url));

    print('Received response with status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('Decoded JSON data: $jsonData');
      final employee = EmployeeModel.fromJson(jsonData['employee']);
      return employee;
    } else {
      print('Failed to load data: ${response.body}');
      throw Exception('Failed to load employee details');
    }
  }

  // Function to update the employee's profile picture
  static Future<void> updateProfilePicture(
      int employeeId, File imageFile) async {
    final url = Uri.parse(
        'https://api.gsutil.xyz/employee/$employeeId/update/profile-picture');
    final request = http.MultipartRequest('PATCH', url);

    // Attach the image file to the request
    request.files.add(await http.MultipartFile.fromPath(
      'profile_picture', // The field name must match the server's expectation
      imageFile.path,
      contentType: MediaType('image', 'jpeg'), // Use MediaType from http_parser
    ));

    try {
      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Check the status code and handle the response
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        final profilePictureUrl = jsonResponse['url'];
        print(
            'Profile picture updated successfully. New URL: $profilePictureUrl');
      } else {
        print('Failed to update profile picture: ${response.statusCode}');
        print('Response body: $responseBody');
        throw Exception('Failed to update profile picture');
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      throw Exception('Error updating profile picture: $e');
    }
  }

  // Function to update employee details (name, NIC, phone number)
  static Future<void> updateEmployeeDetails(int employeeId,
      {String? name, String? nic, String? phoneNo}) async {
    final url = Uri.parse('$baseUrl/employee/$employeeId/update');
    final headers = {'Content-Type': 'application/json'};

    // Create the request body
    final requestBody = jsonEncode({
      'name': name,
      'nic': nic,
      'phone_no': phoneNo,
    });

    try {
      // Send the request
      final response =
          await http.patch(url, headers: headers, body: requestBody);

      // Check the status code and handle the response
      if (response.statusCode == 200) {
        print('Employee details updated successfully.');
      } else {
        print('Failed to update employee details: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update employee details');
      }
    } catch (e) {
      print('Error updating employee details: $e');
      throw Exception('Error updating employee details: $e');
    }
  }
}
