class InvoiceModle {
  final String referenceNumber;
  final int clientId;
  final int employeeId;
  final double totalAmount;
  final double paidAmount;
  final double balance;
  final double discount;
  final String creditPeriodEndDate;
  final String paymentOption;
  final List<InvoiceProduct> products;

  InvoiceModle({
    required this.referenceNumber,
    required this.clientId,
    required this.employeeId,
    required this.totalAmount,
    required this.paidAmount,
    required this.balance,
    required this.discount,
    required this.creditPeriodEndDate,
    required this.paymentOption,
    required this.products,
  });

  factory InvoiceModle.fromJson(Map<String, dynamic> json) {
    return InvoiceModle(
      referenceNumber: json['reference_number'] as String,
      clientId: json['client_id'] as int,
      employeeId: json['employee_id'] as int,
      totalAmount: json['total_amount'] as double,
      paidAmount: json['paid_amount'] as double,
      balance: json['balance'] as double,
      discount: json['discount'] as double,
      creditPeriodEndDate: json['credit_period_end_date'] as String,
      paymentOption: json['payment_option'] as String,
      products: (json['products'] as List)
          .map((productJson) => InvoiceProduct.fromJson(productJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference_number': referenceNumber,
      'client_id': clientId,
      'employee_id': employeeId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'balance': balance,
      'discount': discount,
      'credit_period_end_date': creditPeriodEndDate,
      'payment_option': paymentOption,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class InvoiceProduct {
  final int productId;
  final int batchId;
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
