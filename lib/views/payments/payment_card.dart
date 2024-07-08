import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/payments_modle.dart';
import '../../utils/app_colors.dart';

class PaymentCard extends StatefulWidget {
  final Payment payment;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const PaymentCard({
    Key? key,
    required this.payment,
    required this.onEdit,
    required this.onRemove,
  }) : super(key: key);

  @override
  _PaymentCardState createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  bool _isPressed = false;
  Offset _tapPosition = Offset.zero;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    // Extracting month abbreviation and date from createdAt
    final DateTime createdDate = DateTime.parse(widget.payment.createdAt);
    final String monthAbbreviation = DateFormat('MMM').format(createdDate);
    final String day = DateFormat('dd').format(createdDate);

    // Formatting amount
    final String amountFormatted = 'LKR ${widget.payment.amount}';

    // Payment state and color
    bool isVerified = widget.payment.state == 'verified';
    String stateText = isVerified ? 'Verified' : 'Not Verified';
    Color stateColor = isVerified ? AppColor.successColor : AppColor.errorColor;

    return GestureDetector(
      onTapDown: (details) {
        _storePosition(details);
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onLongPress: () {
        final RenderBox overlay =
            Overlay.of(context)!.context.findRenderObject() as RenderBox;
        showMenu(
          context: context,
          position: RelativeRect.fromRect(
            _tapPosition & const Size(40, 40), // Smaller rect, the tap position
            Offset.zero & overlay.size, // Bigger rect, the entire screen
          ),
          items: <PopupMenuEntry<dynamic>>[
            PopupMenuItem<dynamic>(
              child: ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(
                      context); // Close the menu before triggering the action
                  widget.onEdit();
                },
              ),
            ),
            const PopupMenuDivider(height: 1),
            PopupMenuItem<dynamic>(
              child: ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove'),
                onTap: () {
                  Navigator.pop(
                      context); // Close the menu before triggering the action
                  widget.onRemove();
                },
              ),
            ),
          ],
        );
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
                  monthAbbreviation,
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.payment.referenceNumber,
                    style: GoogleFonts.poppins(
                      color: AppColor.primaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Payment: ${widget.payment.paymentOption}',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      color: AppColor.idTextColorDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: stateColor,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          stateText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: stateColor,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Amount',
                  style: GoogleFonts.poppins(
                    color: AppColor.primaryTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$amountFormatted',
                  style: GoogleFonts.poppins(
                    color: AppColor.primaryTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
