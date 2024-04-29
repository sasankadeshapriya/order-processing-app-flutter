class Vehicle {
  final int id;
  final String vehicleNo;
  final String name;
  final String type;
  final bool assigned;

  Vehicle({
    required this.id,
    required this.vehicleNo,
    required this.name,
    required this.type,
    required this.assigned,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int? ?? 0,
      vehicleNo: json['vehicle_no'] as String? ?? '',
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      assigned: false,
    );
  }

  // Default dummy Vehicle
  factory Vehicle.dummy() {
    return Vehicle(
        id: -1,
        vehicleNo: 'N/A',
        name: 'Not assigned',
        type: 'N/A',
        assigned: false);
  }
}
