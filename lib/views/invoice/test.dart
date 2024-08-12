Future<void> postInvoiceData(
  List<ProcessedProduct> processedProducts,
  InvoiceService invoiceService,
  BuildContext context,
  String selectedPaymentMethod, // Assume this is either 'cheque' or 'cash'
  bool
      _isOutstandingBalancePaid, // True if the outstanding balance is paid, false otherwise
) async {
  try {
    final totalAmount = tempTotalPriceWithDiscount;
    final invoiceProducts = processedProducts.map((processedProduct) {
      return InvoiceProduct(
        productId: processedProduct.product.id,
        batchId: processedProduct.product.sku,
        quantity: processedProduct.quantity,
        sum: processedProduct.sum,
      );
    }).toList();

    // Additional fields based on payment type and balance status
    Map<String, dynamic> additionalFields = {
      'auto':
          _isOutstandingBalancePaid, // Automatically determine based on balance status
      'payment_option': selectedPaymentMethod.toLowerCase(),
    };

    if (selectedPaymentMethod == 'cheque') {
      additionalFields.addAll({
        'bank':
            'Specify Bank Name', // Placeholder, set dynamically or via user input
        'cheque_number': 'Specify Cheque Number', // Placeholder
        'cheque_date': 'Specify Cheque Date', // Placeholder
      });
    }

    if (_isOutstandingBalancePaid) {
      additionalFields['amount_allocated'] =
          calculateAllocationAmount(); // Define or get this value as required
    }

    // Create invoice object
    final invoice = InvoiceModle(
      referenceNumber: generateInvoiceNumber(),
      clientId: selectedClient!.clientId,
      employeeId: empId!,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      balance: outstandingBalance,
      discount: getDiscountAmount(),
      creditPeriodEndDate:
          calculateCreditPeriodEndDate(selectedClient!.creditPeriod ?? 0),
      products: invoiceProducts,
    );

    // Combine common fields with specific payment fields
    final invoiceData = invoice.toJson();
    invoiceData.addAll(additionalFields);

    Logger().w('Posting invoice data...');
    final postResult = await invoiceService.postInvoiceData(invoiceData);

    // Handle result
    Logger().w('Invoice data post result: $postResult');
    handleInvoicePostResult(postResult, context);
  } catch (e) {
    Logger().e('Error posting invoice data: $e');
    AleartBox.showAleart(context, DialogType.error, 'Error',
        'An error occurred while posting invoice data: $e');
  }
}

// Define this method if not already defined
double calculateAllocationAmount() {
  // Implement logic to calculate allocation amount
  return 0.0; // Placeholder return value
}
