import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:order_processing_app/models/client.dart';
import 'package:order_processing_app/models/invoice_mod.dart';
import 'package:order_processing_app/utils/logger.dart';
import 'package:logger/logger.dart';

class InvoiceService {
  
  static const String baseUrl = 'https://api.gsutil.xyz';

  //get all invoices
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

  //get client by id
  static Future<Client> getClientById(int clientId) async {
    final response = await http.get(Uri.parse('$baseUrl/client/$clientId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Client.fromJson(data);
    } else {
      throw Exception('Failed to get client details');
    }
  }
  
  //get client balance
  static Future<double> getClientBalance(int clientId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/invoice'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Search for the invoice corresponding to the selected client
        final invoice = jsonResponse['invoices']
            .firstWhere((invoice) => invoice['client_id'] == clientId, orElse: () => null);
        if (invoice != null) {
          // If the client has an invoice, return its balance
          final balance = double.tryParse(invoice['balance'] ?? '0') ?? 0;
          // Print the response data using logger
          Logger().f('Response data: $jsonResponse');
          return balance;
        } else {
          // If the client does not have an invoice, return 0 balance
          return 0;
        }
      } else {
        // Handle HTTP error
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors
      throw Exception('Error: $e');
    }
  }

}
