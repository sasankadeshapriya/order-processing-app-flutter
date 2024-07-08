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
  final int vehicleInventoryId;
  final double intialqty;

  Product(
      {required this.employeeName,
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
      required this.vehicleInventoryId,
      required this.intialqty});

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
          vehicleInventoryId: 0,
          intialqty: 0.0);
    }
    return Product(
        employeeName: json['employeeName'] as String? ?? 'Unknown',
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? 'Unknown',
        productCode: json['productCode'] as String? ?? 'No Code',
        measurementUnit: json['measurementUnit'] as String? ?? 'Unit',
        description:
            json['description'] as String? ?? 'No Description Available',
        productImage:
            json['productImage'] as String? ?? 'https://placeholder.com/150',
        cashPrice: (json['cashPrice'] as num?)?.toDouble() ?? 0.0,
        checkPrice: (json['checkPrice'] as num?)?.toDouble() ?? 0.0,
        creditPrice: (json['creditPrice'] as num?)?.toDouble() ?? 0.0,
        sku: json['sku'] as String? ?? 'No SKU',
        assignmentId: json['assignmentId'] as int? ?? 0,
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
        vehicleInventoryId: json['vehicleInventoryId'] as int? ?? 0,
        intialqty: (json['intialqty'] as num?)?.toDouble() ?? 0.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeName': employeeName,
      'id': id,
      'name': name,
      'productCode': productCode,
      'measurementUnit': measurementUnit,
      'description': description,
      'productImage': productImage,
      'cashPrice': cashPrice,
      'checkPrice': checkPrice,
      'creditPrice': creditPrice,
      'sku': sku,
      'assignmentId': assignmentId,
      'quantity': quantity,
      'vehicleInventoryId': vehicleInventoryId,
      'intialqty': intialqty,
    };
  }
}
