class CommissionModel {
  int id;
  int empId;
  String date;
  String commission;
  String createdAt;
  String updatedAt;

  CommissionModel({
    required this.id,
    required this.empId,
    required this.date,
    required this.commission,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommissionModel.fromJson(Map<String, dynamic> json) {
    return CommissionModel(
      id: json['id'],
      empId: json['emp_id'],
      date: json['date'],
      commission: json['commission'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
