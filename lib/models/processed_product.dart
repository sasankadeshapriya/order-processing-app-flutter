import 'product_modle.dart';

class ProcessedProduct {
  final Product product;
  final double quantity;
  final double price;
  final double sum;

  ProcessedProduct({
    required this.product,
    required this.quantity,
    required this.price,
    required this.sum,
  });
}
