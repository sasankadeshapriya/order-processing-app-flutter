import 'package:logger/logger.dart';

class Product {
  final String employeeName;
  final int id;
  final String name;
  final String productCode;
  final String measurementUnit;
  final String description;
  final String productImage;
  final double cashPrice;
  final double checkPrice;
  final double creditPrice;
  final String sku;
  final int assignmentId;
  final double quantity; 

  Product({
    required this.employeeName,
    required this.id,
    required this.name,
    required this.productCode,
    required this.measurementUnit,
    required this.description,
    required this.productImage,
    required this.cashPrice,
    required this.checkPrice,
    required this.creditPrice,
    required this.sku,
    required this.assignmentId,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic>? json) {
  if (json == null) {
    Logger().w("Product JSON is null, returning default product.");
    return Product(
      employeeName: 'Unknown',
      id: 0,
      name: 'Unknown',
      productCode: 'No Code',
      measurementUnit: 'Unit',
      description: 'No Description Available',
      productImage: 'https://placeholder.com/150',
      cashPrice: 0.0,
      checkPrice: 0.0,
      creditPrice: 0.0,
      sku: 'No SKU',
      assignmentId: 0,
      quantity: 0.0,
    );
  }
  return Product(
    employeeName: json['employeeName'] ?? 'Unknown',
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? 'Unknown',
    productCode: json['productCode'] as String? ?? 'No Code',
    measurementUnit: json['measurementUnit'] as String? ?? 'Unit',
    description: json['description'] as String? ?? 'No Description',
    productImage: json['productImage'] as String? ?? 'https://placeholder.com/150',
    cashPrice: double.tryParse(json['cashPrice'].toString()) ?? 0.0,
    checkPrice: double.tryParse(json['checkPrice'].toString()) ?? 0.0,
    creditPrice: double.tryParse(json['creditPrice'].toString()) ?? 0.0,
    sku: json['sku'] as String? ?? 'No SKU',
    assignmentId: json['assignmentId'] as int? ?? 0,
    quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
  );
}

}

class ProductResponse {
  final String employeeName;
  final List<Product> products;

  ProductResponse({
    required this.employeeName,
    required this.products,
  });

  factory ProductResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null || json['products'] == null) {
      Logger().w("ProductResponse JSON is null or missing 'products', returning default values.");
      return ProductResponse(
        employeeName: 'Unknown',
        products: [],
      );
    }
    List<dynamic> productJsonList = json['products'] as List;
    List<Product> products = productJsonList.map((productJson) => Product.fromJson(productJson as Map<String, dynamic>)).toList();
    return ProductResponse(
      employeeName: json['employeeName'] ?? 'Unknown',
      products: products,
    );
  }
}
