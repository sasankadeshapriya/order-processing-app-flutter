class EmployeeModel {
  final int id;
  final String name;
  final String? email; // Keep nullable annotation
  final String? profilePicture; // Keep nullable annotation
  final double commissionRate; // Include new properties from stashed changes
  final String? phoneNo; // Include new properties from stashed changes
  final String? nic; // Include new properties from stashed changes

  EmployeeModel({
    required this.id,
    required this.name,
    this.email,
    this.profilePicture,
    required this.commissionRate, // Initialize in constructor from stashed changes
    this.phoneNo, // Initialize in constructor from stashed changes
    this.nic, // Initialize in constructor from stashed changes
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    var employeeData = json['employee'] ?? json;

    return EmployeeModel(
      id: employeeData['id'],
      name: employeeData['name'],
      email: employeeData['email'],

      profilePicture: employeeData['profile_picture'] as String?,
      commissionRate:
          double.parse(employeeData['commission_rate']?.toString() ?? '0'),
      phoneNo: employeeData['phoneNo'] as String?, // Deserialize from JSON
      nic: employeeData['nic'] as String?, // Deserialize from JSON
    );
  }
}
