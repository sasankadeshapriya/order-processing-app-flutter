import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:order_processing_app/models/client.dart';
import 'package:order_processing_app/models/invoice_mod.dart';
import 'package:order_processing_app/utils/logger.dart';

class InvoiceApiService {
  static const String baseUrl = 'http://api.gsutil.xyz';

  static Future<List<Invoice>> getInvoices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/invoice'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['invoices'];
        AppLogger.logInfo('Data received: $data'); // Add print statement here
        return data
            .map((json) => Invoice(
                  id: json['id'],
                  referenceNumber: json['reference_number'],
                  clientId: json['client_id'],
                  employeeId: json['employee_id'],
                  totalAmount: double.parse(json['total_amount']),
                  paidAmount: double.parse(json['paid_amount']),
                  balance: double.parse(json['balance']),
                  discount: double.parse(json['discount']),
                  creditPeriodEndDate:
                      DateTime.parse(json['credit_period_end_date']),
                  paymentOption: json['payment_option'],
                  createdAt: DateTime.parse(json['createdAt']),
                  updatedAt: DateTime.parse(json['updatedAt']),
                ))
            .toList();
      } else {
        AppLogger.logError(
            'Failed to load invoices: ${response.statusCode}'); // Add print statement here
        throw Exception('Failed to load invoices');
      }
    } catch (e) {
      AppLogger.logError(
          'Error fetching invoices: $e'); // Add print statement here
      throw Exception('Error: $e');
    }
  }

  static Future<Client> getClientById(int clientId) async {
    final response = await http.get(Uri.parse('$baseUrl/client/$clientId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Client.fromJson(data);
    } else {
      throw Exception('Failed to get client details');
    }
  }
}
