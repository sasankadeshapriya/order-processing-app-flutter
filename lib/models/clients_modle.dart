import 'package:flutter/material.dart';

class Client {
  final int clientId;
  final String organizationName;
  final String name;
  final IconData icon;
  final double discount;
  final double? latitude;
  final double? longitude;
  final String? phoneNo;
  final int? addedByEmployeeId;
  final String? status; // Added field for status
  final double? creditLimit; // Added field for credit limit
  final int? creditPeriod; // Added field for credit period
  final int? routeId;

  Client({
    this.clientId = 0,
    this.organizationName = 'Unknown',
    this.name = 'Unknown',
    this.icon = Icons.person,
    this.discount = 0.0,
    this.latitude,
    this.longitude,
    this.phoneNo,
    this.addedByEmployeeId,
    this.status,
    this.creditLimit,
    this.creditPeriod,
    this.routeId,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      clientId: json['clientId'] as int? ?? 0,
      organizationName: json['organizationName'] as String? ?? 'Unknown',
      name: json['name'] as String? ?? 'Unknown',
      icon: Icons.person, // Icons can't be parsed from JSON, use default
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0.0,
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      phoneNo: json['phone_no'] as String?,
      addedByEmployeeId: json['added_by_employee_id'] as int?,
      status: json['status'] as String?,
      creditLimit: double.tryParse(json['credit_limit']?.toString() ?? ''),
      creditPeriod: int.tryParse(json['credit_period']?.toString() ?? ''),
      routeId: int.tryParse(json['route_id']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson({bool forPost = false}) {
    var data = <String, dynamic>{};
    if (!forPost) {
      // Fields for GET
      data['id'] = clientId;
      data['organization_name'] = organizationName;
      data['name'] = name;
      data['discount'] = discount;
      // Icon is not serialized
    } else {
      // Fields for POST
      data['organization_name'] = organizationName;
      data['name'] = name;
      data['latitude'] = latitude;
      data['longitude'] = longitude;
      data['phone_no'] = phoneNo;
      data['added_by_employee_id'] = addedByEmployeeId;
      data['status'] = status;
      data['credit_limit'] = creditLimit;
      data['credit_period'] = creditPeriod;
      data['route_id'] = routeId;
      data['discount'] = discount;
    }
    return data;
  }
}
