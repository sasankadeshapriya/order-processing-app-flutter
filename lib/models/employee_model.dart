class EmployeeModel {
  final int id;
  final String? name;
  final String email;
  final String? phoneNo;
  final String? nic;
  final String? profilePicture;

  EmployeeModel({
    required this.id,
    this.name,
    required this.email,
    this.phoneNo,
    this.nic,
    this.profilePicture,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNo: json['phone_no'],
      nic: json['nic'],
      profilePicture: json['profile_picture'],
    );
  }
}


class EmpCommissionModel {
  final double commissionRate;

  EmpCommissionModel({required this.commissionRate});

  factory EmpCommissionModel.fromJson(Map<String, dynamic> json) {
    var employeeData = json['employee'] ?? {};
    double parsedRate = 0;
    try {
      parsedRate =
          double.parse(employeeData['commission_rate']?.toString() ?? '0');
    } catch (e) {
      throw Exception("Failed to parse commission rate: $e");
    }
    return EmpCommissionModel(commissionRate: parsedRate);
  }
}
