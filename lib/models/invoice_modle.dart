class InvoiceModle {
  final int? id; // Make id optional and nullable
  final String referenceNumber;
  final int clientId;
  final int employeeId;
  final double totalAmount;
  final double paidAmount;
  final double balance;
  final double discount;
  final String creditPeriodEndDate; // Keep as String
  final String paymentOption;
  final DateTime? createdAt; // Make createdAt optional and nullable
  final DateTime? updatedAt; // Make updatedAt optional and nullable
  String? organizationName;
  final List<InvoiceProduct> products;

  InvoiceModle({
    this.id, // Optional parameter
    required this.referenceNumber,
    required this.clientId,
    required this.employeeId,
    required this.totalAmount,
    required this.paidAmount,
    required this.balance,
    required this.discount,
    required this.creditPeriodEndDate, // Keep as required String
    required this.paymentOption,
    this.createdAt, // Optional parameter
    this.updatedAt, // Optional parameter
    this.organizationName,
    required this.products,
  });

  factory InvoiceModle.fromJson(Map<String, dynamic> json) {
    return InvoiceModle(
      id: json['id'],
      referenceNumber: json['reference_number'],
      clientId: json['client_id'],
      employeeId: json['employee_id'],
      totalAmount: double.parse(json['total_amount']),
      paidAmount: double.parse(json['paid_amount']),
      balance: double.parse(json['balance']),
      discount: double.parse(json['discount']),
      creditPeriodEndDate: json['credit_period_end_date'], // Keep as String
      paymentOption: json['payment_option'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      organizationName: json['organization_name'],
      products: (json['products'] as List)
          .map((productJson) => InvoiceProduct.fromJson(productJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference_number': referenceNumber,
      'client_id': clientId,
      'employee_id': employeeId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'balance': balance,
      'discount': discount,
      'credit_period_end_date': creditPeriodEndDate, // Keep as String
      'payment_option': paymentOption,
      'createdAt': createdAt?.toIso8601String(), // Optional field
      'updatedAt': updatedAt?.toIso8601String(), // Optional field
      'organization_name': organizationName,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class InvoiceProduct {
  final int productId;
  final String batchId;
  final double quantity;
  final double sum;

  InvoiceProduct({
    required this.productId,
    required this.batchId,
    required this.quantity,
    required this.sum,
  });

  factory InvoiceProduct.fromJson(Map<String, dynamic> json) {
    return InvoiceProduct(
      productId: json['product_id'] as int,
      batchId: json['batch_id'],
      quantity: json['quantity'],
      sum: json['sum'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'batch_id': batchId,
      'quantity': quantity,
      'sum': sum,
    };
  }
}
