import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  //fetch products
  static Future<List<dynamic>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('https://api.gsutil.xyz/product'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load products');
    }
  }
}
