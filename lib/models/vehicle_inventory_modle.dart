class VehicleInventory {
  final double quantity;
  final String sku;
  final int productId;
  final int addedByAdminId;
  final int assignmentId;

  VehicleInventory({
    required this.quantity,
    required this.sku,
    required this.productId,
    required this.addedByAdminId,
    required this.assignmentId,
  });

  factory VehicleInventory.fromJson(Map<String, dynamic> json) {
    return VehicleInventory(
      quantity: json['quantity'],
      sku: json['sku'] as String,
      productId: json['product_id'] as int,
      addedByAdminId: json['added_by_admin_id'] as int,
      assignmentId: json['assignmentId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'sku': sku,
      'product_id': productId,
      'added_by_admin_id': addedByAdminId,
      'assignment_id': assignmentId,
    };
  }
}
