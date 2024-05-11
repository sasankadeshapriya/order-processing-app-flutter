import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ProductService {
  static const String baseUrl = 'https://api.gsutil.xyz';

  static Future<Map<String, dynamic>> fetchProducts(
      int empId, String currentDate) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fetchdata/$empId/$currentDate'),
      );

      //Logger().i('Response bodyqqqqqqqqqqqqqqqqqqqqqq: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final employeeName = responseData['employee_name'];
        final vehicleInventory = responseData['vehicle_inventory'];

        final products = vehicleInventory.map((vehicle) {
          final productData = vehicle['Product'];
          final batches = productData['Batches'];
          final firstBatch = batches.isNotEmpty ? batches.first : {};

          final quantityString = vehicle['quantity'] as String? ?? '0.0';
          final quantity = double.tryParse(quantityString) ?? 0.0;

          return {
            'employeeName': employeeName,
            'id': productData['id'],
            'name': productData['name'],
            'sku': vehicle['sku'],
            'productCode': productData['product_code'],
            'measurementUnit': productData['measurement_unit'],
            'description': productData['description'],
            'productImage': productData['product_image'],
            'cashPrice': firstBatch['cash_price'],
            'checkPrice': firstBatch['check_price'],
            'creditPrice': firstBatch['credit_price'],
            'assignmentId': vehicle['assignment_id'],
             'quantity': quantity,
            // 'quantity' : vehicle['quantity'],
          };
        }).toList();

        Logger().i('details inside api service class :$products');

        return {
          //'employeeName': employeeName,
          'products': products,
        };
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      Logger().e('Error fetching products: $error');
      rethrow;
    }
  }
}
