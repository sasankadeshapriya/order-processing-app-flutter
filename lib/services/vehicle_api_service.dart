import 'package:order_processing_app/models/vehicle.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleApiService {
  static const String baseUrl = 'https://api.gsutil.xyz';
  static Future<List<Vehicle>> getAllVehicles() async {
    final response = await http.get(Uri.parse('$baseUrl/vehicles'));
    if (response.statusCode == 200) {
      List<dynamic> vehiclesJson = json.decode(response.body);
      List<Vehicle> vehicles =
          vehiclesJson.map((json) => Vehicle.fromJson(json)).toList();
      return vehicles;
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  static Future<Vehicle> getVehicleDetailsById(int vehicleId) async {
    final response = await http.get(Uri.parse('$baseUrl/vehicles/$vehicleId'));
    if (response.statusCode == 200) {
      return Vehicle.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Vehicle not found');
    } else {
      throw Exception('Failed to load vehicle');
    }
  }
}
