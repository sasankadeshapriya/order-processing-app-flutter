import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/clients_modle.dart';

class ClientCard extends StatefulWidget {
  final Client client;
  final VoidCallback onPressed;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const ClientCard({
    super.key,
    required this.client,
    required this.onPressed,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  _ClientCardState createState() => _ClientCardState();
}

class _ClientCardState extends State<ClientCard> {
  bool _isPressed = false;
  Offset _tapPosition = Offset.zero;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
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
        widget.onPressed();
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
            // Explicitly declare the list type
            PopupMenuItem<dynamic>(
              // Specify the generic type for PopupMenuItem
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                onTap: () {
                  Navigator.pop(
                      context); // Close the menu before triggering the action
                  widget.onEdit();
                },
              ),
            ),
            PopupMenuDivider(
                height: 1), // PopupMenuDivider is already the correct type
            PopupMenuItem<dynamic>(
              // Specify the generic type for PopupMenuItem
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove'),
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
        margin: const EdgeInsets.only(left: 8, right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFFB7BABA) : Colors.white,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFB6B9B9),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.client.organizationName ?? 'Unknown',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF565656),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      Text(
                        widget.client.status ?? 'Unknown',
                        style: GoogleFonts.poppins(
                          color: widget.client.status == 'verified'
                              ? Colors.green
                              : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.client.name ?? 'Unknown',
                    style: const TextStyle(
                      color: Color(0xFFA3A2A9),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  Text(
                    widget.client.phoneNo ?? 'No phone number',
                    style: const TextStyle(
                      color: Color(0xFFA3A2A9),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro Text',
                    ),
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
