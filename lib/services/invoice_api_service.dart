import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:order_processing_app/models/invoice_mod.dart';
import 'package:order_processing_app/models/invoice_modle.dart';
import 'package:order_processing_app/models/sales_invoice.dart';
import 'package:order_processing_app/utils/logger.dart';

import '../models/clients_modle.dart';

class InvoiceService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

// get all invoices
  static Future<List<Invoice>> getInvoices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/invoice'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['invoices'];
        Logger().f('Data received: $data');
        return data.map((json) => Invoice.fromJson(json)).toList();
      } else {
        AppLogger.logError('Failed to load invoices: ${response.statusCode}');
        throw Exception('Failed to load invoices');
      }
    } catch (e) {
      AppLogger.logError('Error fetching invoices: $e');
      throw Exception('Error: $e');
    }
  }

  // get client by id
  static Future<Client> getClientById(int clientId) async {
    try {
      print('Fetching client details for client ID: $clientId');
      final response = await http.get(Uri.parse('$baseUrl/client/$clientId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Client data received for client ID $clientId: $data');
        return Client.fromJson(data);
      } else {
        throw Exception('Failed to get client details');
      }
    } catch (e) {
      print('Error fetching client details for client ID: $clientId: $e');
      throw Exception('Error: $e');
    }
  }

  //get client balance
  static Future<double> getClientBalance(int clientId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/invoice'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Search for the invoice corresponding to the selected client
        final invoice = jsonResponse['invoices'].firstWhere(
            (invoice) => invoice['client_id'] == clientId,
            orElse: () => null);
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

  Future<Map<String, dynamic>> postInvoiceData(InvoiceModle invoice) async {
    final String apiUrl = '$baseUrl/invoice';
    try {
      final String requestBody = jsonEncode(invoice.toJson());
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      Logger().f('Sending request to $apiUrl');
      Logger().f('Request body: $requestBody');

      if (response.statusCode == 201) {
        Logger().i('Invoice successfully created');
        Logger().i('Response body: ${response.body}');
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        Logger()
            .w('Failed to create invoice. Status code: ${response.statusCode}');
        Logger().w('Response body: ${response.body}');

        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody.containsKey('message')) {
          Logger().w('Error message: ${responseBody['message']}');
        }
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to create invoice',
        };
      }
    } catch (e) {
      Logger().e('Exception occurred while sending data: $e');
      return {'success': false, 'message': 'Exception occurred: $e'};
    }
  }

  // Function to fetch invoices by employee ID
  static Future<List<SalesInvoice>> fetchInvoicesByEmployeeId(
      int employeeId) async {
    final url = Uri.parse('$baseUrl/invoice/employee/$employeeId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => SalesInvoice.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load invoices');
    }
  }
}
