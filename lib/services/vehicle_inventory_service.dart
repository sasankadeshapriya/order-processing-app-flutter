import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/vehicle_inventory_modle.dart';

class VehicleInventoryService {
  final String baseUrl = 'https://api.gsutil.xyz';

  Future<bool> updateVehicleInventory(
      int assignmentId, VehicleInventory vehicleInventory) async {
    final url = '$baseUrl/vehicle-inventory/$assignmentId';

    // Create an instance of the logger
    final logger = Logger();

    // Convert the vehicle inventory to JSON
    final body = jsonEncode(vehicleInventory.toJson());

    // Log the request details
    logger.i('Sending PUT request to: $url');
    logger.i('Request Headers: ${{
      'Content-Type': 'application/json',
    }}');
    logger.i('Request Body: $body');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Log the response details
      logger.i('Received response: $response');
      logger.i('Response status code: ${response.statusCode}');
      logger.i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Update successful
        logger.i('Vehicle inventory updated successfully.');
        return true;
      } else {
        // Handle error response
        logger.i('Failed to update vehicle inventory: ${response.body}');
        return false;
      }
    } catch (error) {
      // Handle request error
      logger.i('Error updating vehicle inventory: $error');
      return false;
    }
  }

  Future<Map<String, dynamic>> deleteVehicleInventory(int inventoryId) async {
    Logger().i('Attempting to delete vehicle inventory with ID: $inventoryId');
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/vehicle-inventory/$inventoryId'),
        headers: {
          'Content-Type': 'application/json',
          // Add other headers like authorization if needed
        },
      );

      Logger().i(
          'Received HTTP status code: ${response.statusCode} for inventory ID: $inventoryId');

      if (response.statusCode == 200) {
        Logger()
            .i('Successfully deleted vehicle inventory with ID: $inventoryId');
        return {
          'success': true,
          'message': 'Vehicle inventory deleted successfully',
        };
      } else {
        Logger().i(
            'Failed to delete vehicle inventory with ID: $inventoryId. Response: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to delete vehicle inventory: ${response.body}'
        };
      }
    } catch (e) {
      Logger().i(
          'Error occurred while deleting vehicle inventory with ID: $inventoryId: $e');
      return {
        'success': false,
        'message': 'An error occurred while deleting vehicle inventory: $e'
      };
    }
  }
}
