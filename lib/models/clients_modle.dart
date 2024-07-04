import 'package:flutter/material.dart';

class Client {
  final int clientId;
  late final String? name;
  late final String? organizationName;
  final IconData icon;
  final double discount;
  late final double? latitude;
  late final double? longitude;
  late final String? phoneNo;
  final int? addedByEmployeeId;
  final String? status;
  final double? creditLimit;
  final int? creditPeriod;
  final int? routeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    this.clientId = 0,
    this.name = 'Unknown Client Name ',
    this.organizationName = 'Unknown',
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
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    // Logger().w('JSON received: $json');

    json.forEach((key, value) {
      // Log the field name and its data type
      // Logger().f('$key data type: ${value.runtimeType}');
    });

    return Client(
      clientId: json['id'] as int,
      name: json['name'] as String?,
      organizationName: json['organization_name'] as String?,
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
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson({bool forPost = false}) {
    var data = <String, dynamic>{
      'clientId': clientId,
      'organization_name': organizationName,
      'name': name,
      'discount': discount,
      'latitude': latitude,
      'longitude': longitude,
      'phone_no': phoneNo,
      'added_by_employee_id': addedByEmployeeId,
      'status': status,
      'credit_limit': creditLimit,
      'credit_period': creditPeriod,
      'route_id': routeId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
    if (!forPost) {
      data.remove('latitude');
      data.remove('longitude');
      data.remove('phone_no');
      data.remove('added_by_employee_id');
      data.remove('status');
      data.remove('credit_limit');
      data.remove('credit_period');
      data.remove('route_id');
      data.remove('createdAt');
      data.remove('updatedAt');
    }
    return data;
  }
}
