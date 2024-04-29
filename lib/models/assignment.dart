class Assignment {
  final int id;
  final int employeeId;
  late final String assignDate;
  final int vehicleId;
  final String vehicleNo;
  final int routeId;
  final String routeName;
  final int addedByAdminId;

  Assignment({
    required this.id,
    required this.employeeId,
    required this.assignDate,
    required this.vehicleId,
    required this.vehicleNo,
    required this.routeId,
    required this.routeName,
    required this.addedByAdminId,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    print(
        'JSON received in Assignment.fromJson: $json'); // Debug print statement

    DateTime? date = DateTime.tryParse(json['assignment_date']);
    print('Parsed Date from JSON: $date'); // More detailed debug statement

    if (date == null && json['assign_date'] != null) {
      print('Failed to parse date from value: ${json['assignment_date']}');
    }

    return Assignment(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      assignDate: date?.toString() ?? 'No Date Provided',
      vehicleId: json['vehicle_id'] ?? 0,
      vehicleNo: json['vehicle_number'] ?? 'N/A',
      routeId: json['route_id'] ?? 0,
      routeName: json['route_name'] ?? 'No Route Assigned',
      addedByAdminId: json['added_by_admin_id'] ?? 0,
    );
  }
}
