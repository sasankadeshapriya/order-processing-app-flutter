import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../components/alert_dialog.dart';
import '../models/clients_modle.dart';
import '../models/invoice_modle.dart'; // Import Invoice and InvoiceProduct
import '../models/payments_modle.dart';
import '../models/processed_product.dart'; // Import the existing ProcessedProduct model
import '../models/product_modle.dart';
import '../models/product_response.dart';
import '../models/vehicle_inventory_modle.dart';
import '../services/client_api_service.dart';
import '../services/commission_api_service.dart';
import '../services/invoice_api_service.dart';
import '../services/product_api_service.dart';
import '../services/vehicle_inventory_service.dart';
import '../views/main/dashboard.dart';
import 'util_functions.dart';

class InvoiceLogic {
  late List<Client> clients;
  late List<Product> productList;
  late Map<Product, double> productQuantities;
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;
  Product? selectedProduct;
  Client? selectedClient;
  late String _token;
  late int? empId = 1; // change after debug
  String employeeName = '';
  String invoiceErrorMessage = '';
  double? _outstandingBalance = 0.0;
  double? totalPrice = 0.0;
  bool isFullyPaid = false;
  bool isPartiallyPaid = false;
  double paidAmount = 0.0;
  double totalPaybleAmount = 0.0;
  final Map<int, TextEditingController> _quantityControllers = {};
  double get outstandingBalance => _outstandingBalance ?? 0.0;

  InvoiceLogic() {
    clients = [];
    productList = [];
    productQuantities = {};
    _token = '';
    selectedPaymentMethod = null;
    selectedProduct = null;
    paymentMethods = PaymentMethod.getListFromHardCodedData();
  }

  void updateSelectedPaymentMethod(String paymentMethodName) {
    selectedPaymentMethod = paymentMethods.firstWhere(
      (paymentMethod) => paymentMethod.paymentName == paymentMethodName,
      orElse: () => selectedPaymentMethod as PaymentMethod,
    );
  }

  set outstandingBalance(double value) {
    _outstandingBalance = value;
  }

  bool canPrintInvoice() {
    if (selectedClient == null ||
        selectedPaymentMethod == null ||
        productQuantities.isEmpty) {
      invoiceErrorMessage =
          'You must select a client, a payment method, and at least one product before you can print the invoice.';
      return false;
    } else if (!isFullyPaid && !isPartiallyPaid) {
      invoiceErrorMessage =
          'You must add a payment before you can print the invoice.';
      return false;
    }
    invoiceErrorMessage = '';
    return true;
  }

  List<Map<String, dynamic>> getFormattedProductDetails() {
    return productQuantities.entries.map((entry) {
      final product = entry.key;
      final quantity = entry.value;
      final double price = getPrice(product, selectedPaymentMethod!);
      final double amount = price * quantity;
      return {
        'title': product.name,
        'price': price.toStringAsFixed(2),
        'quantity': quantity,
        'amount': amount.toStringAsFixed(2),
      };
    }).toList();
  }

  void disposeControllers() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    _quantityControllers.clear();
  }

  TextEditingController getControllerForProduct(Product product) {
    return _quantityControllers.putIfAbsent(
      product.id,
      () => TextEditingController(
        text: productQuantities[product]?.toStringAsFixed(1) ?? '0.0',
      ),
    );
  }

  Future<void> getOutstandingBalance(int clientId) async {
    try {
      _outstandingBalance = await InvoiceService.getClientBalance(clientId);
      Logger().i('Outstanding balance updated: $_outstandingBalance');
    } catch (e) {
      Logger().e('Error fetching client balance: $e');
      _outstandingBalance = 0;
    }
  }

  Future<void> fetchClients(BuildContext context) async {
    try {
      final clientData = await ClientService.getClients();
      clients = clientData;
    } catch (error) {
      Logger().e('Error fetching clients: $error');

      // User-friendly error message initialization
      String userFriendlyMessage =
          "We're having trouble loading client information right now.";

      // Determine a user-friendly message based on the error type
      if (error.toString().contains('TimeoutException')) {
        userFriendlyMessage =
            "Connection timed out. Please check your internet connection and try again.";
      } else if (error.toString().contains('SocketException')) {
        userFriendlyMessage =
            "Unable to connect. Please check your network settings.";
      } else if (error.toString().contains('HttpException')) {
        userFriendlyMessage =
            "Trouble connecting to the server. Please try again later.";
      } else {
        userFriendlyMessage =
            "An unexpected error occurred. Please try again later.";
      }

      // Optionally, use a dialog to communicate the error to the user
      if (context != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error'),
            content: Text(userFriendlyMessage),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> fetchProductDetails(
      int empId, String currentDate, BuildContext context) async {
    try {
      ProductResponse productResponse =
          await ProductService.fetchProducts(empId, currentDate);
      productList = productResponse.products;
      employeeName = productResponse.employeeName;
      // Now you can use productList and employeeName in your logic
    } catch (error) {
      Logger().e('Error fetching product details: $error');

      // Determine a user-friendly message based on the type of error
      String userFriendlyMessage =
          "We're unable to load the products at this moment.";
      if (error.toString().contains('TimeoutException')) {
        userFriendlyMessage =
            "Connection timed out. Please check your internet connection and try again.";
      } else if (error.toString().contains('SocketException')) {
        userFriendlyMessage =
            "Unable to connect. Please check your network settings.";
      } else if (error.toString().contains('HttpException')) {
        userFriendlyMessage =
            "Trouble connecting to the server. Please try again later.";
      }

      // Show Awesome Dialog with a user-friendly error message
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Failed to Load Products',
        desc: userFriendlyMessage,
        btnOkOnPress: () {},
      ).show();
    }
  }

  String generateInvoiceNumber() {
    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyyMMddHHmmss').format(now);
    return 'INV-${empId ?? 'UNKNOWN'}-$formattedDateTime';
  }

  void resetPaymentStatus() {
    isFullyPaid = false;
    isPartiallyPaid = false;
  }

  int getSelectedProductCount() {
    return productQuantities.values.where((quantity) => quantity > 0).length;
  }

  void selectPaymentMethod(PaymentMethod? paymentMethod) {
    selectedPaymentMethod = paymentMethod;
  }

  void increaseQuantity(Product product) {
    productQuantities[product] = (productQuantities[product] ?? 0) + 1;
  }

  void decreaseQuantity(Product product, {double decrement = 1.0}) {
    final currentQuantity = productQuantities[product] ?? 0.0;
    productQuantities[product] =
        currentQuantity > decrement ? currentQuantity - decrement : 0.0;
  }

  void updateProductQuantity(Product product, double newQuantity) {
    productQuantities[product] = newQuantity;
  }

  void addSelectedProduct(Product product) {
    selectedProduct = product;
    productQuantities.putIfAbsent(product, () => 1);
  }

  void removeSelectedProduct(Product product) {
    selectedProduct = null;
    productQuantities.remove(product);
  }

  double getPrice(Product product, PaymentMethod paymentMethod) {
    switch (paymentMethod.paymentName) {
      case 'Cash':
        return product.cashPrice;
      case 'Credit':
        return product.creditPrice;
      case 'Cheque':
        return product.checkPrice;
      default:
        return 0.0;
    }
  }

  double getTotalBillAmount() {
    return productQuantities.entries.fold(0.0, (total, entry) {
      final product = entry.key;
      final quantity = entry.value;
      final price = getPrice(product, selectedPaymentMethod!);
      return total + (price * quantity);
    });
  }

  double getDiscountAmount() {
    if (selectedClient != null && selectedClient!.discount > 0) {
      final totalBill = getTotalBillAmount();
      return totalBill * (selectedClient!.discount / 100);
    }
    return 0.0;
  }

  Future<double> getTotalPriceWithDiscount() async {
    final totalBill = getTotalBillAmount();
    final discount = getDiscountAmount();
    return totalBill - discount + (outstandingBalance);
  }

  Future<void> calculateTotalPaybleAmount() async {
    totalPaybleAmount = await getTotalPriceWithDiscount();
    //Logger().i('Total Payable Amount: $totalPaybleAmount');
  }

  void updateTotalPaybleAmount(double newTotalPaybleAmount) {
    totalPaybleAmount = newTotalPaybleAmount;
    Logger().i('Total Payable Amount updated: $totalPaybleAmount');
  }

  Future<void> printProductList() async {
    Logger().d("Printing product list with ${productList.length} items.");
    for (final product in productList) {
      Logger().d('Product: ${product.toJson()}');
    }
  }

  Future<void> processInvoiceData(
    VehicleInventoryService vehicleInventoryService,
    InvoiceService invoiceService,
    BuildContext context,
  ) async {
    final processedProducts = processProducts();

    await updateVehicleInventory(
        processedProducts, vehicleInventoryService, context);
    await postInvoiceData(processedProducts, invoiceService, context);
  }

  List<ProcessedProduct> processProducts() {
    return productQuantities.entries.map((entry) {
      final product = entry.key;
      final quantity = entry.value;
      final price = getPrice(product, selectedPaymentMethod!);
      return ProcessedProduct(
        product: product,
        quantity: quantity,
        price: price,
        sum: price * quantity,
      );
    }).toList();
  }

  Future<void> updateVehicleInventory(
    List<ProcessedProduct> processedProducts,
    VehicleInventoryService vehicleInventoryService,
    BuildContext context,
  ) async {
    // Function to validate and parse quantity input
    double parseQuantity(String input) {
      // Add a leading zero if the input starts with a decimal point
      if (input.startsWith('.')) {
        input = '0$input';
      }

      // Try to parse the input as a double
      try {
        return double.parse(input);
      } catch (e) {
        Logger().e('Invalid quantity input: $input');
        return 0.0;
      }
    }

    // Flag to track if any product update was successful
    bool updateSuccessful = false;

    for (final processedProduct in processedProducts) {
      // Validate and parse the quantity input
      final inputQuantity = processedProduct.quantity;
      final validQuantity = parseQuantity(inputQuantity.toString());

      // Use the quantity from the Product class to get the current available stock
      final currentAvailableStock = processedProduct.product.quantity;

      // Calculate new available stock
      final newAvailableStock = currentAvailableStock - validQuantity;
      if (newAvailableStock < 0) {
        Logger().e(
            'Not enough stock for product ID: ${processedProduct.product.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Not enough stock for product ID: ${processedProduct.product.id}'),
            duration: const Duration(seconds: 2),
          ),
        );
        continue;
      }

      // Update vehicle inventory with new available stock
      final vehicleInventory = VehicleInventory(
        quantity: newAvailableStock,
        sku: processedProduct.product.sku,
        productId: processedProduct.product.id,
        addedByAdminId: empId!,
        assignmentId: processedProduct.product.assignmentId,
      );

      // Send updated inventory to the database
      final success = await vehicleInventoryService.updateVehicleInventory(
        processedProduct.product.vehicleInventoryId,
        vehicleInventory,
      );

      if (success) {
        updateSuccessful = true; // Set flag to true if update is successful
        Logger().i(
            'Vehicle inventory updated for product ID: ${processedProduct.product.id}');
      } else {
        Logger().e(
            'Failed to update vehicle inventory for product ID: ${processedProduct.product.id}');
      }
    }

    // Show a single SnackBar after updating all products
    if (updateSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle inventory updated successfully'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update vehicle inventory for some products'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    }
  }

  Future<void> postInvoiceData(
    List<ProcessedProduct> processedProducts,
    InvoiceService invoiceService,
    BuildContext context,
  ) async {
    try {
      final totalAmount = await getTotalPriceWithDiscount();

      final invoiceProducts = processedProducts.map((processedProduct) {
        return InvoiceProduct(
          productId: processedProduct.product.id,
          batchId: processedProduct.product.sku,
          quantity: processedProduct.quantity,
          sum: processedProduct.sum,
        );
      }).toList();

      final invoice = InvoiceModle(
        referenceNumber: generateInvoiceNumber(),
        clientId: selectedClient!.clientId,
        employeeId: empId!,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        balance: outstandingBalance,
        discount: getDiscountAmount(),
        creditPeriodEndDate:
            UtilFunctions.getCurrentDateTime(includeTime: true),
        paymentOption: selectedPaymentMethod!.paymentName.toLowerCase(),
        products: invoiceProducts,
      );

      Logger().w('Posting invoice data...');

      final postResult = await invoiceService.postInvoiceData(invoice);

      Logger().w('Invoice data post result: $postResult');

      if (postResult['success']) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          headerAnimationLoop: false,
          animType: AnimType.bottomSlide,
          title: 'Success',
          desc: 'Invoice data has been successfully saved.',
          btnOkOnPress: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const UserDashboard()));
          },
          // Customize the OK button text if needed
          btnOkText: 'OK',
          // Customize the OK button's text color if needed
          btnOkColor: Colors.green,
        ).show();
      } else {
        AleartBox.showAleart(context, DialogType.error, 'Error',
            postResult['message'] ?? 'Unknown error occurred.');
      }
    } catch (e) {
      Logger().e('Error posting invoice data: $e');
      AleartBox.showAleart(context, DialogType.error, 'Error',
          'An error occurred while posting invoice data: $e');
    }
  }

  //Employee commition added function
  Future<void> AddCommission(double totalBillAmount) async {
    try {
      int empId = 1; // Assuming static for example purposes
      String date =
          UtilFunctions.getCurrentDateTime(); // Get current date and time

      Logger().i(
          "Attempting to add/update commission with amount: $totalBillAmount");

      if (totalBillAmount <= 0) {
        Logger().w("Commission amount is zero or negative. Aborting API call.");
        return;
      }

      var result =
          await CommissionService.addCommission(empId, date, totalBillAmount);
      Logger().i("Commission successfully added/updated: $result");
    } catch (e) {
      Logger().e("Failed to add/update commission: ${e.toString()}");
    }
  }
}
