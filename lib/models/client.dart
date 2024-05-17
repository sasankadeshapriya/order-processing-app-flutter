class Client {
  final int id;
  final String name;
  final String organizationName;
  final String latitude;
  final String longitude;
  final String? phoneNo;
  final String status;
  final double discount;
  final double creditLimit;
  final int creditPeriod;
  final int routeId;
  final int addedByEmployeeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.organizationName,
    required this.latitude,
    required this.longitude,
    this.phoneNo,
    required this.status,
    required this.discount,
    required this.creditLimit,
    required this.creditPeriod,
    required this.routeId,
    required this.addedByEmployeeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      organizationName: json['organization_name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      phoneNo: json['phone_no'],
      status: json['status'],
      discount: double.parse(json['discount'].toString()),
      creditLimit: double.parse(json['credit_limit'].toString()),
      creditPeriod: json['credit_period'],
      routeId: json['route_id'],
      addedByEmployeeId: json['added_by_employee_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
