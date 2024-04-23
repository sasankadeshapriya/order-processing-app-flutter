import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_processing_app/utils/app_colors.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          border: Border.all(color: AppColor.widgetStroke),
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
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  'APR',
                  style: GoogleFonts.poppins(
                    color: AppColor.primaryColorLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const Text(
                  '12',
                  style: TextStyle(
                    color: AppColor.primaryColorLight,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "empName",
                    style: GoogleFonts.poppins(
                      color: AppColor.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'INV45',
                        style: GoogleFonts.poppins(
                          color: AppColor.idTextColorDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColor.widgetBackgroundColor,
                          border: Border.all(
                            color: AppColor.successColor,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Received',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: AppColor.successColor,
                                  fontSize: 8,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'LKR 21,000.00',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    color: AppColor.primaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  'LKR 00.00',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    color: AppColor.primaryTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
