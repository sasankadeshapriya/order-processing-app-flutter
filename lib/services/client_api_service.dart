import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// Import the logger package

class ClientService {
  static const String baseUrl = 'https://api.gsutil.xyz';

  // Fetch clients
  static Future<List<dynamic>> fetchClients() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/client'));

      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        List<dynamic> clients = responseData.map((client) {
          // Extract organization_name and assign a default icon
          return {
            'clientId': client['id'],
            'organizationName': client['organization_name'],
            'name': client['name'],
            'icon': Icons.person,
            'discount':client['discount'] // Set a default icon for each client
          };
        }).toList();
        //Logger().f('Client Response body: ${response.body}');
        //Logger().i(clients); // Print responseData list using logger.info

        return clients;
      } else {
        throw Exception('Failed to fetch clients: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching clients: $error');
      rethrow;
    }
  }
}
