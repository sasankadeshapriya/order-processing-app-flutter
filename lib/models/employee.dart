class Employee {
  final String name;
  final int id;
  final String imageUrl;
  final int assigned;

  Employee({
    required this.name,
    required this.id,
    required this.imageUrl,
    required this.assigned,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    final assignedValue = json['assigned'];
    final assigned = assignedValue ?? 0;
    return Employee(
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      assigned: assigned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'imageUrl': imageUrl,
      'assigned': assigned,
    };
  }
}
