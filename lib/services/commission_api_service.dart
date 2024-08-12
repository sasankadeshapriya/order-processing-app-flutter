// CommissionService.dart
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:order_processing_app/models/commission_modle.dart';

class CommissionService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  static Future<CommissionModel> addCommission(
      int empId, String date, double commissionAmount) async {
    final url = '$baseUrl/commission/add';
    final String requestBody = jsonEncode(<String, dynamic>{
      'emp_id': empId,
      'date': date,
      'commission': commissionAmount,
    });

    // Log the request data for debugging
    Logger().f('Preparing to send POST request to $url');
    Logger().f('Request Body: $requestBody');

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );

    // Log the response status and body for debugging
    Logger().f('Received response with status code: ${response.statusCode}');
    Logger().f('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return CommissionModel.fromJson(jsonData['commission']);
    } else {
      // Log error before throwing
      Logger().w(
          'Failed to add/update commission. Status code: ${response.statusCode}');
      Logger().w('Response Body: ${response.body}');
      throw Exception(
          'Failed to add/update commission. Status code: ${response.statusCode}');
    }
  }

  static Future<List<CommissionModel>> getCommissionsByEmpId(int empId) async {
    final url = '$baseUrl/commission/emp/$empId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<CommissionModel> commissions = (jsonData['commissions'] as List)
          .map((json) => CommissionModel.fromJson(json))
          .toList();
      return commissions;
    } else {
      throw Exception('Failed to load commissions');
    }
  }

  static Future<List<CommissionModel>> getTodaysCommissions(
      List<CommissionModel> commissions) async {
    final today = DateTime.now();
    final todaysCommissions = commissions.where((commission) {
      final commissionDate = DateTime.parse(commission.date).toLocal();
      return commissionDate.year == today.year &&
          commissionDate.month == today.month &&
          commissionDate.day == today.day;
    }).toList();
    return todaysCommissions;
  }
}
