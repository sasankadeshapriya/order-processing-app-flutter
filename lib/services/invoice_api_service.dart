import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class InvoiceService {
  static const String baseUrl = 'https://api.gsutil.xyz';

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
