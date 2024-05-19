import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:order_processing_app/utils/app_colors.dart';

class AssignmentCard extends StatelessWidget {
  final String date;
  final String routeName;
  final String vehicleNumber;

  const AssignmentCard({
    super.key,
    required this.date,
    required this.routeName,
    required this.vehicleNumber,
  });

  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(date);
    DateTime today = DateTime.now();
    bool isToday = parsedDate.year == today.year &&
        parsedDate.month == today.month &&
        parsedDate.day == today.day;

    // Determine the styling based on whether the date is past, today, or future
    Color borderColor;
    Color textColor;
    String labelText;
    if (isToday) {
      borderColor = AppColor.successColor;
      textColor = AppColor.successColor;
      labelText = 'Today';
    } else if (parsedDate.isBefore(today)) {
      borderColor = AppColor.errorColor;
      textColor = AppColor.errorColor;
      labelText = 'Passed';
    } else {
      borderColor = Colors.yellow[700]!;
      textColor = Colors.yellow[800]!;
      labelText = 'Upcoming';
    }

    String month = DateFormat('MMM').format(parsedDate).toUpperCase();
    String day = DateFormat('d').format(parsedDate);

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: GoogleFonts.poppins(
                    color: AppColor.primaryColorLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  day,
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
                    routeName,
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
                        vehicleNumber,
                        style: GoogleFonts.poppins(
                          color: AppColor.secondaryTextColorDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColor.widgetBackgroundColor,
                          border: Border.all(
                            color: borderColor,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                labelText,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: textColor,
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
          ],
        ),
      ),
    );
  }
}
