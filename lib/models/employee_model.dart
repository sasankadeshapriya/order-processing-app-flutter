class EmployeeModel {
  final int id;
  final String name;
  final String? email; // This is already nullable
  final String? profilePicture; // Make profilePicture nullable

  EmployeeModel({
    required this.id,
    required this.name,
    this.email,
    this.profilePicture, // Accept nullable profilePicture
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePicture:
          json['profile_picture'] as String?, // Safely cast as nullable String
    );
  }
}
