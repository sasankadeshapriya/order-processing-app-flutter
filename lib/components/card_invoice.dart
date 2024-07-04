import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:order_processing_app/utils/app_colors.dart';

class InvoiceCard extends StatelessWidget {
  final String organizationName;
  final String createdAt;
  final String creditPeriodEndDate;
  final double paidAmount;
  final double totalAmount;
  final String referenceNumber;

  const InvoiceCard({
    super.key,
    required this.organizationName,
    required this.createdAt,
    required this.creditPeriodEndDate,
    required this.paidAmount,
    required this.totalAmount,
    required this.referenceNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Extracting month abbreviation and date from createdAt
    final DateTime createdDate = DateTime.parse(createdAt);
    final String monthAbbreviation = DateFormat('MMM').format(createdDate);
    final String day = DateFormat('dd').format(createdDate);

    // Formatting creditPeriodEndDate as month/day
    final DateTime endDate = DateTime.parse(creditPeriodEndDate);
    final String endDateFormatted = DateFormat('MM/dd').format(endDate);

    // Calculating whether the invoice is fully or partially received
    bool fullyReceived = paidAmount == totalAmount;
    String statusText = fullyReceived ? 'Received' : 'Partially received';
    Color statusColor =
        fullyReceived ? AppColor.successColor : AppColor.processingColor;

    return GestureDetector(
      onTap: () {
        // Define action on tap if necessary
      },
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
                  monthAbbreviation, // Displaying month abbreviation
                  style: GoogleFonts.poppins(
                    color: AppColor.primaryColorLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  day, // Displaying day
                  style: const TextStyle(
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
                    organizationName,
                    style: GoogleFonts.poppins(
                      color: AppColor.primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    referenceNumber,
                    style: GoogleFonts.poppins(
                      color: AppColor.idTextColorDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: statusColor,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          statusText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: statusColor,
                            fontSize: 8,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'LKR $totalAmount',
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
                Row(
                  children: [
                    Text(
                      endDateFormatted, // Displaying formatted end date
                      style: GoogleFonts.poppins(
                        color: AppColor.primaryTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'LKR $paidAmount',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        color: AppColor.primaryTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
