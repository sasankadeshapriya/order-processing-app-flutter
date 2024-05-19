import 'package:logger/logger.dart';

import 'product_modle.dart'; // Ensure you have the correct import path

class ProductResponse {
  final String employeeName;
  final List<Product> products;

  ProductResponse({
    required this.employeeName,
    required this.products,
  });

  factory ProductResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null || json['products'] == null) {
      Logger().w(
          "ProductResponse JSON is null or missing 'products', returning default values.");
      return ProductResponse(
        employeeName: 'Unknown',
        products: [],
      );
    }
    List<dynamic> productJsonList = json['products'] as List<dynamic>;
    List<Product> products = productJsonList.map((productJson) {
      return Product.fromJson(productJson as Map<String, dynamic>);
    }).toList();

    return ProductResponse(
      employeeName: json['employeeName'] as String? ?? 'Unknown',
      products: products,
    );
  }
}
