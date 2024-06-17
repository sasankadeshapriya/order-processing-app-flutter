// CommissionService.dart
import 'package:http/http.dart' as http;
import 'package:order_processing_app/models/commission_modle.dart';
import 'dart:convert';

class CommissionService {
  static const String baseUrl = 'http://api.gsutil.xyz';

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
