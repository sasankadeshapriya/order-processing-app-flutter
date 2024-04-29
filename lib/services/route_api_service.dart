import 'package:order_processing_app/models/route.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteApiService {
  static const String baseUrl = 'https://api.gsutil.xyz';

  static Future<List<Route>> getAllRoutes() async {
    final response = await http.get(Uri.parse('$baseUrl/routes'));
    if (response.statusCode == 200) {
      List<dynamic> routesJson = json.decode(response.body);
      List<Route> routes =
          routesJson.map((json) => Route.fromJson(json)).toList();
      return routes;
    } else {
      throw Exception('Failed to load routes');
    }
  }

  static Future<Route> getRouteDetailsById(int routeId) async {
    final response = await http.get(Uri.parse('$baseUrl/routes/$routeId'));
    if (response.statusCode == 200) {
      return Route.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Route not found');
    } else {
      throw Exception('Failed to load route');
    }
  }
}
