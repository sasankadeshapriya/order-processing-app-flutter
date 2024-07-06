import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_modle.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onPressed;
  final double openingStock;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onPressed,
    required this.openingStock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split the product name into words
    List<String> nameParts = product.name.split(' ');

    // Join the first part of the words for the first line
    String firstLine = nameParts.isNotEmpty ? nameParts.first : product.name;

    // Join the remaining part of the words for the second line
    String secondLine =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFB7BABA)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              spreadRadius: 0,
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(product.productImage),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstLine,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF565656),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (secondLine.isNotEmpty)
                        Text(
                          secondLine,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF565656),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stock Cash Value',
                      style: const TextStyle(
                        color: Color(0xFFA3A2A9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                    Text(
                      '${(product.quantity * product.cashPrice).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFA3A2A9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFB7BABA)),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Table(
                border: TableBorder.symmetric(
                  inside: BorderSide(color: Color(0xFFB7BABA)),
                ),
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Cash Price',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                              Text(
                                '\Rs.${product.cashPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Credit Price',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                              Text(
                                '\Rs.${product.creditPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Cheque Price',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                              Text(
                                '\Rs.${product.checkPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Opening Stock',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                              Text(
                                '${openingStock.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Out Stock',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                              Text(
                                '${calculateOutStock(openingStock, product.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Available Stock',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                              Text(
                                '${product.quantity.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFA3A2A9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateOutStock(double openingStock, double availableStock) {
    return openingStock - availableStock;
  }
}
