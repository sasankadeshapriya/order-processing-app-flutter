import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:order_processing_app/models/route.dart';
import 'package:order_processing_app/models/vehicle.dart';
import 'package:order_processing_app/utils/logger.dart';

class AssignmentApiService {
  static const String baseUrl = 'https://api.gsutil.xyz';

  // Centralized HTTP request function
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

  // Process assignments to generate detailed list
  static List<Map<String, dynamic>> processAssignments(
      List<dynamic> assignments, List<Vehicle> vehicles, List<Route> routes) {
    return assignments.map((assignment) {
      final Vehicle vehicle = vehicles.firstWhere(
          (v) => v.id == assignment['vehicle_id'],
          orElse: () => Vehicle.dummy());
      final Route route = routes.firstWhere(
          (r) => r.id == assignment['route_id'],
          orElse: () => Route.dummy());

      Map<String, dynamic> detailedAssignment = {
        'assignment_date': assignment['assign_date'] ?? 'Date Not Available',
        'vehicle_number': vehicle.vehicleNo,
        'route_name': route.name,
      };
      print("Processed assignment details: $detailedAssignment");
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
}
