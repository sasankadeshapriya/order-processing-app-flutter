import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../models/clients_modle.dart';
import '../models/payments_modle.dart';
import '../models/product_modle.dart';
import '../services/client_api_service.dart';
import '../services/invoice_api_service.dart';
import '../services/product_api_service.dart';

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
  // Payment section
  double? _outstandingBalance = 0.0;
  double? totalPrice = 0.0;
  bool isFullyPaid = false;
  bool isPartiallyPaid = false; 
  double paidAmount = 0.0;
  double totalPaybleAmount = 0.0;
  final Map<int, TextEditingController> _quantityControllers = {};
  double get outstandingBalance => _outstandingBalance ?? 0.0;

  // Constructor
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
        orElse: () => selectedPaymentMethod as PaymentMethod);
  }

  set outstandingBalance(double value) {
    _outstandingBalance = value;
  }
  bool canPrintInvoice() {
  // Check if client, payment method, and at least one product have been selected
  return selectedClient != null &&
         selectedPaymentMethod != null &&
         productQuantities.isNotEmpty;
}
 List<Map<String, dynamic>> getFormattedProductDetails() {
    List<Map<String, dynamic>> productDetails = [];
    
    productQuantities.forEach((product, quantity) {
      final double price = getPrice(product, selectedPaymentMethod!);
      final double amount = price * quantity;
      productDetails.add({
        'title': product.name,
        'price': price.toStringAsFixed(2),
        'quantity': quantity,
        'amount': amount.toStringAsFixed(2),
      });
    });

    return productDetails;
  }


  void disposeControllers() {
    _quantityControllers.forEach((_, controller) => controller.dispose());
    _quantityControllers.clear();
  }

  TextEditingController getControllerForProduct(Product product) {
    int key = product.id; // Use int ID directly
    if (!_quantityControllers.containsKey(key)) {
      _quantityControllers[key] = TextEditingController(
          text: '${productQuantities[product]?.toStringAsFixed(1) ?? '0.0'}');
    }
    return _quantityControllers[key]!;
  }

  Future<void> getOutstandingBalance(int clientId) async {
    try {
      double _Balance = await InvoiceService.getClientBalance(clientId);
      _outstandingBalance = _Balance;
      Logger().i('Outstanding balance updated: $_outstandingBalance');
    } catch (e) {
      Logger().e('Error fetching client balance: $e');
      _outstandingBalance = 0; // Reset on error
    }
  }

  Future<void> fetchClients() async {
    try {
      List<dynamic> clientData = await ClientService.fetchClients();
      clients =
          clientData.map((clientJson) => Client.fromJson(clientJson)).toList();
      clients.forEach((client) {
       // Logger().i(client); // Using info level logging to log client details
      });
    } catch (error) {
      Logger().e('Error fetching clients: $error');
    }
  }

  Future<List<Product>> fetchProductDetails(
      int empId, String currentDate) async {
    //Logger().d("Fetching products with empId: $empId (Type: ${empId.runtimeType}) on date: $currentDate (Type: ${currentDate.runtimeType})");

    try {
      Map<String, dynamic> productData =
          await ProductService.fetchProducts(empId, currentDate);
      // Logger().d("Product data received: ${productData.runtimeType}");

      if (productData.isEmpty ||
          productData['products'] == null ||
          productData['products'].isEmpty) {
        // Logger().w('No products found in the data for empId: $empId on date: $currentDate');
        return []; // Return an empty list
      }

      List<dynamic> products = productData['products'];
      // Logger().d(
      //     "Received products data: ${products.length} items of type ${products.runtimeType}");

      return products
          .map((productJson) {
            try {
              Map<String, dynamic> json = productJson as Map<String, dynamic>;
              // Logger().d("Processing product JSON: $json (Type: ${json.runtimeType})");

              double cashPrice =
                  double.tryParse(json['cashPrice'].toString()) ?? 0.0;
              // Logger().d("Parsed cashPrice: $cashPrice (Type: ${cashPrice.runtimeType})");
              double checkPrice =
                  double.tryParse(json['checkPrice'].toString()) ?? 0.0;
              // Logger().d("Parsed checkPrice: $checkPrice (Type: ${checkPrice.runtimeType})");
              double creditPrice =
                  double.tryParse(json['creditPrice'].toString()) ?? 0.0;
              //Logger().d("Parsed creditPrice: $creditPrice (Type: ${creditPrice.runtimeType})");
              double quantity =
                  double.tryParse(json['quantity'].toString()) ?? 0.0;
              //Logger().d("Parsed quantity: $quantity (Type: ${quantity.runtimeType})");

              Product product = Product(
                employeeName: json['employeeName'],
                id: json['id'],
                name: json['name'],
                sku: json['sku'],
                productCode: json['productCode'],
                measurementUnit: json['measurementUnit'],
                description: json['description'],
                productImage: json['productImage'],
                cashPrice: cashPrice,
                checkPrice: checkPrice,
                creditPrice: creditPrice,
                assignmentId: json['assignmentId'],
                quantity: quantity,
              );

              // Logger().d("Created product instance: $product (Type: ${product.runtimeType})");
              return product;
            } catch (e) {
              Logger().e(
                'Error processing product JSON: $e',
              );
              return null; // This will be filtered out
            }
          })
          .where((product) => product != null)
          .cast<Product>()
          .toList();
    } catch (error) {
      Logger().e('Error fetching product details:$error');
      return []; // Return an empty list on error
    }
  }

  String generateInvoiceNumber() {
    // Get the current date and time
    DateTime now = DateTime.now();
    // Format the date and time components
    String formattedDateTime = DateFormat('yyyyMMddHHmmss').format(now);
    // Combine the components to form the invoice number
    String invoiceNumber = 'INV-${empId ?? 'UNKNOWN'}-$formattedDateTime';
    return invoiceNumber;
  }

  // Future<void> retrieveEmpId() async {
  // final String? token = await TokenManager.getToken();
  // if (token != null) {
  //   try {
  //     Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  //     empId = decodedToken['userId'] as int?;
  //   } catch (e) {
  //     print('Error decoding token: $e');
  //   }
  // }
//}

  int getSelectedProductCount() {
    int count = 0;
    productQuantities.forEach((product, quantity) {
      if (quantity > 0) {
        count++;
      }
    });
    return count;
  }

  void selectPaymentMethod(PaymentMethod? paymentMethod) {
    selectedPaymentMethod = paymentMethod;
  }

  void increaseQuantity(Product product) {
    productQuantities[product] = (productQuantities[product] ?? 1) + 1;
  }

  void decreaseQuantity(Product product, {double decrement = 1.0}) {
    double currentQuantity = productQuantities[product] ?? 1.0;
    if (currentQuantity > decrement) {
      productQuantities[product] = currentQuantity - decrement;
    } else {
      productQuantities[product] = 0.0; // Optional: prevent negative quantities
    }
  }

  void updateProductQuantity(Product product, double newQuantity) {
    // Check if the product exists in the productQuantities map
    if (productQuantities.containsKey(product)) {
      // Update the quantity of the product
      productQuantities[product] = newQuantity;
    }
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
    double total = 0.0;
    productQuantities.forEach((product, quantity) {
      double price = getPrice(product, selectedPaymentMethod!) * quantity;

      total += price;
    });
    Logger().i("Total bill amount calculated: $total");
    return total;
  }

  double getDiscountAmount() {
    if (selectedClient != null && selectedClient!.discount > 0) {
      double totalBill = getTotalBillAmount();
      double discount = totalBill * (selectedClient!.discount / 100);
      Logger().i(
          "Total bill for discount: $totalBill, Discount Rate: ${selectedClient!.discount}%, Discount Amount: $discount");
      return discount;
    }
    return 0.0;
  }

  Future<double> getTotalPriceWithDiscount() async {
    if (selectedClient == null) {
      Logger()
          .w('No selected client when calculating total price with discount.');
      double totalBill = getTotalBillAmount();
      double discount = getDiscountAmount();
      Logger().i(
          "Returning without a selected client: Total Bill - Discount = $totalBill - $discount");
      return totalBill - discount;
    }

    try {
      double totalBillAmount = getTotalBillAmount();
      double discountAmount = getDiscountAmount();
      double totalPrice =
          totalBillAmount - discountAmount + (this.outstandingBalance ?? 0.0);
      Logger().i(
          "Total Price with Discount Calculated: Total Bill - Discount + Outstanding Balance = $totalBillAmount - $discountAmount + ${this.outstandingBalance ?? 0.0} = $totalPrice");
      return totalPrice;
    } catch (e) {
      Logger().w('Error calculating total price with discount: $e');
      double totalBill = getTotalBillAmount();
      double discount = getDiscountAmount();
      Logger().i("Error case: Total Bill - Discount = $totalBill - $discount");
      return totalBill - discount;
    }
  }

  Future<void> calculateTotalPaybleAmount() async {
    totalPaybleAmount = await getTotalPriceWithDiscount();
    // Use totalPaybleAmount as needed
    print('Total Payble Amount: $totalPaybleAmount');
  }

  void updateTotalPaybleAmount(double newTotalPaybleAmount) {
  totalPaybleAmount = newTotalPaybleAmount;
  Logger().i('Total Payable Amount updated: $totalPaybleAmount');
}


  // Function to load invoice page inside a container

  Future<void> printProductList() async {
    Logger().d("Printing product list with ${productList.length} items.");
    for (Product product in productList) {
      Logger().d(
          'Product ID: ${product.id}, Name: ${product.name}, Price: ${product.cashPrice}, Price: ${product.checkPrice},Price: ${product.creditPrice}, Sku :${product.sku},Product Code :${product.productCode},Product Image: ${product.productImage},MeasurementUnit : ${product.measurementUnit},Assignment Id: ${product.assignmentId},Qauntity :${product.quantity}');
    } //
  }
}
