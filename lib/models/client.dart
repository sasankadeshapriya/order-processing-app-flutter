class Client {
  final int id;
  final String? name;
  final String? organizationName;
  final String? latitude;
  final String? longitude;
  final String? phoneNo;
  final String? status;
  final double? discount;
  final double? creditLimit;
  final int? creditPeriod;
  final int? routeId;
  final int? addedByEmployeeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    required this.id,
    this.name,
    this.organizationName,
    this.latitude,
    this.longitude,
    this.phoneNo,
    this.status,
    this.discount,
    this.creditLimit,
    this.creditPeriod,
    this.routeId,
    this.addedByEmployeeId,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'] as String?,
      organizationName: json['organization_name'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      phoneNo: json['phone_no'] as String?,
      status: json['status'] as String?,
      discount: json['discount'] != null
          ? double.tryParse(json['discount'].toString())
          : null,
      creditLimit: json['credit_limit'] != null
          ? double.tryParse(json['credit_limit'].toString())
          : null,
      creditPeriod: json['credit_period'] as int?,
      routeId: json['route_id'] as int?,
      addedByEmployeeId: json['added_by_employee_id'] as int?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
