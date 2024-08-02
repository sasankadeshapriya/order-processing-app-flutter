class EmployeeModel {
  final int id;
  final String name;
  final String? email; // This is already nullable
  final String? profilePicture; // Make profilePicture nullable
  final double commissionRate;

  EmployeeModel({
    required this.id,
    required this.name,
    this.email,
    this.profilePicture, // Accept nullable profilePicture
    required this.commissionRate,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    var employeeData =
        json['employee'] ?? json; // Fallback to root if no employee key

    return EmployeeModel(
      id: employeeData['id'],
      name: employeeData['name'],
      email: employeeData['email'],
      profilePicture: employeeData['profile_picture']
          as String?, // Safely cast as nullable String
      commissionRate:
          double.parse(employeeData['commission_rate']?.toString() ?? '0'),
    );
  }
}
