import 'package:flutter/foundation.dart';

class SalesInvoice {
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
  final List<SalesInvoiceDetail> invoiceDetails;

  SalesInvoice({
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
    required this.invoiceDetails,
  });

  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    var detailList = json['InvoiceDetails'] as List? ?? [];
    List<SalesInvoiceDetail> details = detailList
        .map((detail) => SalesInvoiceDetail.fromJson(detail))
        .toList();

    // Print the raw JSON data for createdAt to debug
    print("Raw createdAt JSON data: ${json['createdAt']}");

    return SalesInvoice(
      referenceNumber: json['reference_number'] as String? ?? '',
      clientId: int.tryParse(json['client_id'].toString()) ?? 0,
      employeeId: int.tryParse(json['employee_id'].toString()) ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      paidAmount: double.tryParse(json['paid_amount'].toString()) ?? 0.0,
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      discount: double.tryParse(json['discount'].toString()) ?? 0.0,
      creditPeriodEndDate: DateTime.parse(
          json['credit_period_end_date'] as String? ??
              DateTime.now().toIso8601String()),
      paymentOption: json['payment_option'] as String? ?? '',
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      invoiceDetails: details,
    );
  }
  @override
  String toString() {
    return 'SalesInvoice(referenceNumber: $referenceNumber, clientId: $clientId, employeeId: $employeeId, totalAmount: $totalAmount, paidAmount: $paidAmount, balance: $balance, discount: $discount, creditPeriodEndDate: $creditPeriodEndDate, paymentOption: $paymentOption, createdAt: $createdAt, invoiceDetails: $invoiceDetails)';
  }
}

class SalesInvoiceDetail {
  final int productId;
  final int batchId;
  final double quantity;
  final double sum;
  final SalesProduct product;

  SalesInvoiceDetail({
    required this.productId,
    required this.batchId,
    required this.quantity,
    required this.sum,
    required this.product,
  });

  factory SalesInvoiceDetail.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceDetail(
      productId: int.tryParse(json['product_id'].toString()) ?? 0,
      batchId: int.tryParse(json['batch_id'].toString()) ?? 0,
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      sum: double.tryParse(json['sum'].toString()) ?? 0.0,
      product:
          SalesProduct.fromJson(json['Product'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SalesProduct {
  final int id;
  final String name;
  final String productCode;
  final String measurementUnit;
  final String description;
  final String productImage;

  SalesProduct({
    required this.id,
    required this.name,
    required this.productCode,
    required this.measurementUnit,
    required this.description,
    required this.productImage,
  });

  factory SalesProduct.fromJson(Map<String, dynamic> json) {
    return SalesProduct(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      productCode: json['product_code'] as String? ?? '',
      measurementUnit: json['measurement_unit'] as String? ?? '',
      description: json['description'] as String? ?? 'No description',
      productImage:
          json['product_image'] as String? ?? 'https://placeholder.com/150',
    );
  }
}
