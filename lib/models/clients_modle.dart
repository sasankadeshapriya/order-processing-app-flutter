import 'package:flutter/material.dart';

class Client {
  final int clientId;
  final String organizationName;
  final String name;
  final IconData icon;
  final double discount;

  Client({
    required this.clientId,
    required this.organizationName,
    required this.name,
    required this.icon,
    required this.discount,
  });

  factory Client.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Client(
        clientId : 0,
        organizationName: 'Unknown',
        name: 'Unknown',
        icon: Icons.person,  // Default icon
        discount: 0.0,  // Default discount
      );
    }

    // Parsing when JSON is not null
    double parsedDiscount = double.tryParse(json['discount']?.toString() ?? '') ?? 0.0;

    return Client(
      clientId : json['clientId'] ?? 0,
      organizationName: json['organizationName'] ?? 'Unknown',
      name: json['name'] ?? 'Unknown',
      icon: Icons.person,  // Default icon
      discount: parsedDiscount,
    );
  }
}
