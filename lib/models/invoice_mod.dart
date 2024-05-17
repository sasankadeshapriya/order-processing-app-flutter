class Invoice {
  final int id;
  final String referenceNumber;
  final int clientId;
  final int employeeId;
  final double totalAmount;
  final double paidAmount;
  final double balance;
  final double discount;
  final DateTime creditPeriodEndDate;
  final String paymentOption;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? organizationName; // Add this field

  Invoice({
    required this.id,
    required this.referenceNumber,
    required this.clientId,
    required this.employeeId,
    required this.totalAmount,
    required this.paidAmount,
    required this.balance,
    required this.discount,
    required this.creditPeriodEndDate,
    required this.paymentOption,
    required this.createdAt,
    required this.updatedAt,
    this.organizationName, // Initialize it
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      referenceNumber: json['reference_number'],
      clientId: json['client_id'],
      employeeId: json['employee_id'],
      totalAmount: double.parse(json['total_amount']),
      paidAmount: double.parse(json['paid_amount']),
      balance: double.parse(json['balance']),
      discount: double.parse(json['discount']),
      creditPeriodEndDate: DateTime.parse(json['credit_period_end_date']),
      paymentOption: json['payment_option'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
