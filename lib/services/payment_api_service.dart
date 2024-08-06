import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/payments_modle.dart';

class PaymentService {
  static final String baseUrl = dotenv.env['BASE_URL']!;
  static final String endpoint = '$baseUrl/payment';
  final Logger _logger = Logger();

  static Future<PaymentResponse> getAllPayments() async {
    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      Logger().i('Payments fetched successfully');
      return PaymentResponse.fromJson(jsonDecode(response.body));
    } else {
      Logger().w('Failed to load payments: ${response.statusCode}');
      throw Exception('Failed to load payments');
    }
  }

  static Future<Map<String, dynamic>> deletePayment(int paymentId) async {
    final response = await http.delete(Uri.parse('$endpoint/$paymentId'));

    if (response.statusCode == 200) {
      Logger().i('Payment deleted successfully');
      return {'success': true};
    } else {
      Logger().e('Failed to delete payment: ${response.statusCode}');
      return {
        'success': false,
        'message': 'Failed to delete payment: ${response.reasonPhrase}'
      };
    }
  }
}
