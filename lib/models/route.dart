import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Route {
  final int id;
  final String name;
  List<dynamic> waypoints;
  final bool assigned;
  final int addedByAdminId;

  Route({
    required this.id,
    required this.name,
    required this.waypoints,
    required this.assigned,
    required this.addedByAdminId,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    final waypointsString = json['waypoints'] ?? '';
    List<dynamic> waypoints = [];

    if (waypointsString is String && waypointsString.isNotEmpty) {
      try {
        waypoints = jsonDecode(waypointsString);
      } catch (e) {
        // log error or handle the exception if the string cannot be parsed
        print('Failed to decode waypoints: $e');
      }
    }

    return Route(
      id: json['id'] as int? ?? 0,
      name: json['name'] ?? '',
      waypoints: waypoints,
      addedByAdminId: json['added_by_admin_id'] as int? ?? 0,
      assigned: false,
    );
  }

  // Default dummy Route
  factory Route.dummy() {
    return Route(
        id: -1,
        name: 'Not assigned',
        waypoints: [],
        assigned: false,
        addedByAdminId: -1);
  }
}
