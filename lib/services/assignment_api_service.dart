import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:order_processing_app/models/route.dart';
import 'package:order_processing_app/models/vehicle.dart';
import 'package:order_processing_app/utils/logger.dart';

class AssignmentApiService {
  static const String baseUrl = 'https://api.gsutil.xyz';
  static const String empbaseUrl = '$baseUrl/employee';

  static Future<dynamic> fetchResource(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    AppLogger.logInfo(
        "Response status code for $endpoint: ${response.statusCode}");
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load $endpoint with status code: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  static Future<List<Map<String, dynamic>>> getAssignmentsWithDetails(
      int employeeId) async {
    try {
      List<dynamic> assignments = await fetchResource('assignment');
      AppLogger.logInfo("Assignments loaded: ${assignments.length} items");
      assignments =
          assignments.where((a) => a['employee_id'] == employeeId).toList();

      if (assignments.isEmpty) {
        AppLogger.logInfo("No assignments found for employee ID: $employeeId");
        return [];
      }

      List<Vehicle> vehicles = await getAllVehicles();
      List<Route> routes = await getAllRoutes();
      return processAssignments(assignments, vehicles, routes);
    } catch (e) {
      AppLogger.logError('An error occurred in getAssignmentsWithDetails: $e');
      return [];
    }
  }

  static List<Map<String, dynamic>> processAssignments(
      List<dynamic> assignments, List<Vehicle> vehicles, List<Route> routes) {
    return assignments.map((assignment) {
      final Vehicle vehicle = vehicles.firstWhere(
          (v) => v.id == assignment['vehicle_id'],
          orElse: () => Vehicle.dummy());
      final Route route = routes.firstWhere(
          (r) => r.id == assignment['route_id'],
          orElse: () => Route.dummy());

      List<LatLng> waypoints = route.waypoints
          .map((wp) => LatLng(double.parse(wp['latitude'].toString()),
              double.parse(wp['longitude'].toString())))
          .toList();

      Map<String, dynamic> detailedAssignment = {
        'assignment_date': assignment['assign_date'] ?? 'Date Not Available',
        'vehicle_number': vehicle.vehicleNo,
        'route_id': route.id,
        'route_name': route.name,
        'waypoints': waypoints,
      };
      print('Processed assignment: $detailedAssignment');
      return detailedAssignment;
    }).toList();
  }

  static Future<List<Vehicle>> getAllVehicles() async {
    try {
      List<dynamic> vehiclesJson = await fetchResource('vehicle');
      return vehiclesJson.map((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      AppLogger.logError('An error occurred in getAllVehicles: $e');
      throw Exception('Error fetching vehicles: $e');
    }
  }

  static Future<List<Route>> getAllRoutes() async {
    try {
      List<dynamic> routesJson = await fetchResource('route');
      return routesJson.map((json) => Route.fromJson(json)).toList();
    } catch (e) {
      AppLogger.logError('An error occurred in getAllRoutes: $e');
      throw Exception('Error fetching routes: $e');
    }
  }

  static Future<void> updateEmployeeLocation(
      String employeeId, Map<String, dynamic> locationData) async {
    try {
      String locationJsonString = jsonEncode(locationData);

      AppLogger.logDebug('Received location data: $locationData');

      final response = await http.put(
        Uri.parse('$empbaseUrl/$employeeId/update/location'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: locationJsonString,
      );

      if (response.statusCode == 200) {
        AppLogger.logDebug('Employee location updated successfully');
      } else {
        AppLogger.logError(
            'Failed to update employee location: ${response.statusCode}');
        throw Exception('Failed to update employee location');
      }
    } catch (e) {
      AppLogger.logError('Error updating employee location: $e');
      throw Exception('Error updating employee location: $e');
    }
  }

  static Future<List<dynamic>> getClientLocationsByRouteId(int routeId) async {
    print("Attempting to fetch client locations for route ID: $routeId");

    try {
      final url = Uri.parse('$baseUrl/client/route/$routeId');
      print("Constructed URL: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('HTTP Status Code: ${response.statusCode}');
      print('HTTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> clients = json.decode(response.body);
        print("Received client data: $clients");
        return clients;
      } else if (response.statusCode == 404) {
        throw Exception('No clients found for this route');
      } else {
        throw Exception('Failed to fetch client locations');
      }
    } catch (e) {
      print('Error occurred while fetching client locations: $e');
      throw Exception('Error fetching client locations: $e');
    }
  }
}
