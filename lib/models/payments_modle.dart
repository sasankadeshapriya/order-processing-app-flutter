import 'package:flutter/material.dart';

class Payment {
  final int id;
  final String referenceNumber;
  final String amount;
  final String paymentOption;
  final String state;
  final String? notes;
  final int addedByEmployeeId;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Payment({
    required this.id,
    required this.referenceNumber,
    required this.amount,
    required this.paymentOption,
    required this.state,
    this.notes,
    required this.addedByEmployeeId,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      referenceNumber: json['reference_number'],
      amount: json['amount'],
      paymentOption: json['payment_option'],
      state: json['state'],
      notes: json['notes'],
      addedByEmployeeId: json['added_by_employee_id'],
      deletedAt: json['deletedAt'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class PaymentResponse {
  final List<Payment> payments;

  PaymentResponse({required this.payments});

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    var paymentsJson = json['payments'] as List;
    List<Payment> paymentsList =
        paymentsJson.map((payment) => Payment.fromJson(payment)).toList();
    return PaymentResponse(payments: paymentsList);
  }
}

class PaymentMethod {
  final int paymentId;
  final String paymentName;
  final IconData paymentIcon;

  PaymentMethod(this.paymentId, this.paymentName, this.paymentIcon);

  // Factory method to generate hard-coded payment methods
  factory PaymentMethod.fromHardCodedData() {
    return PaymentMethod(1, 'Cash', Icons.money);
  }

  // Factory method to generate a list of hard-coded payment methods
  static List<PaymentMethod> getListFromHardCodedData() {
    return [
      PaymentMethod(1, 'Cash', Icons.money),
      PaymentMethod(2, 'Credit', Icons.credit_card),
      PaymentMethod(3, 'Cheque', Icons.account_balance),
    ];
  }
}
