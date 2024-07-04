import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/clients_modle.dart';
// Import the logger package

class ClientService {
  static const String baseUrl = 'https://api.gsutil.xyz';

  // Fetch clients
  // static Future<List<dynamic>> fetchClients() async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/client'));
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> responseData = jsonDecode(response.body);
  //       List<dynamic> clients = responseData.map((client) {
  //         // Extract organization_name and assign a default icon
  //         return {
  //           'clientId': client['id'],
  //           'organization_name': client['organization_name'],
  //           'name': client['name'],
  //           'icon': Icons.person,
  //           'discount': client['discount'] // Set a default icon for each client
  //         };
  //       }).toList();
  //       // Logger().f(
  //       //     'Client Response bodyyyyyyyyyyyyyyyyxxxxxxxxxxxxxxxxxxxxxxxxxxxx: ${response.body}');
  //       //Logger().i(clients); // Print responseData list using logger.info
  //
  //       return clients;
  //     } else {
  //       throw Exception('Failed to fetch clients: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error fetching clients: $error');
  //     rethrow;
  //   }
  // }
// Add New Client
  Future<Map<String, dynamic>> postClientData(Client client) async {
    const String apiUrl = '$baseUrl/client';
    try {
      final String requestBody = jsonEncode(client.toJson(forPost: true));
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      Logger().i('Sending request to $apiUrl');
      Logger().i('Request body: $requestBody');

      if (response.statusCode == 201) {
        Logger().i('Client successfully created');
        Logger().i('Response body: ${response.body}');
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        Logger()
            .w('Failed to create client. Status code: ${response.statusCode}');
        Logger().w('Response body: ${response.body}');

        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody.containsKey('message')) {
          Logger().w('Error message: ${responseBody['message']}');
        }
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to create client',
        };
      }
    } catch (e) {
      Logger().e('Exception occurred while sending data: $e');
      return {'success': false, 'message': 'Exception occurred: $e'};
    }
  }

  //get All client Details
  static Future<List<Client>> getClients() async {
    final response = await http.get(Uri.parse('$baseUrl/client'));

    Logger().i('Fetching clients from $baseUrl/client');
    Logger().i('Response status code: ${response.statusCode}');
    Logger().i('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> clientJson = json.decode(response.body);
      Logger().i('Parsed JSON: $clientJson');

      final clients = clientJson.map((json) => Client.fromJson(json)).toList();
      Logger().i('Mapped clients: $clients');

      return clients;
    } else {
      Logger()
          .e('Failed to load clients with status code: ${response.statusCode}');
      throw Exception('Failed to load clients');
    }
  }

  //Update Existing Client
  Future<Map<String, dynamic>> updateClient(
      int clientId, Map<String, dynamic> clientData) async {
    final String url = '$baseUrl/client/$clientId';

    Logger().i('Request URL: $url');
    Logger().i('Data being sent: $clientData');
    clientData.forEach((key, value) {
      Logger().f('$key type: ${value.runtimeType}');
    });
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add any other headers if necessary, such as authorization tokens
      },
      body: jsonEncode(clientData),
    );
    Logger().i('Response Status Code: ${response.statusCode}');
    Logger().i('Response Body: ${response.body}');
    final decodedBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Logger().i('Decoded Response Body: $decodedBody');
      return {
        'success': true,
        'message': 'Client updated successfully',
        'data': jsonDecode(response.body),
      };
    } else {
      Logger().w('Failed to update client: ${decodedBody['message']}');

      return {
        'success': false,
        'message': jsonDecode(response.body)['message'],
        'data': null,
      };
    }
  }

  //Deleting Existing Client
  static Future<Map<String, dynamic>> deleteClient(int clientId) async {
    final String apiUrl = '$baseUrl/client/$clientId';
    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          // Include any other headers like authorization tokens if required
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Client deleted successfully',
        };
      } else {
        // Handling unexpected status codes
        return {
          'success': false,
          'message':
              json.decode(response.body)['message'] ?? 'An error occurred',
        };
      }
    } catch (e) {
      // Handling exceptions on sending request
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
