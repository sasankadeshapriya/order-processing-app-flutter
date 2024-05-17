import 'package:flutter/material.dart';

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
