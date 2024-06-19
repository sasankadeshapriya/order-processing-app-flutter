import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:order_processing_app/models/employee_model.dart';

class EmployeeService {
  static const String baseUrl = 'https://api.gsutil.xyz';
  static final Map<int, EmployeeModel> _cache = {};

  static Future<EmployeeModel> getEmployeeDetails(int id) async {
    print('Fetching details for employee with ID: $id');

    if (_cache.containsKey(id)) {
      print('Returning cached data for employee ID: $id');
      return _cache[id]!;
    }

    final url = '$baseUrl/employee/$id/details';
    print('Requesting data from URL: $url');
    final response = await http.get(Uri.parse(url));

    print('Received response with status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('Decoded JSON data: $jsonData');
      final employee = EmployeeModel.fromJson(jsonData['employee']);
      _cache[id] = employee; // Cache the fetched employee data
      print('Employee data cached for ID: $id');
      return employee;
    } else {
      print('Failed to load data: ${response.body}');
      throw Exception('Failed to load employee details');
    }
  }
}
