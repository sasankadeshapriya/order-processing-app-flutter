import 'package:flutter/material.dart';

class FloatingContainer extends StatelessWidget {
  final String vehicleNumber;
  final String routeName;
  final String date;
  final int clientCount;

  const FloatingContainer({
    super.key,
    required this.vehicleNumber,
    required this.routeName,
    required this.date,
    required this.clientCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Container(
            width: double.infinity,
            height: 152,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF9EA0A0), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  offset: Offset(0, 7),
                  blurRadius: 25,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employee Tracking',
                    style: TextStyle(
                      color: Color(0xFF565656),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.route_outlined,
                          size: 16, color: Color(0xFFA3A2A9)),
                      const SizedBox(width: 8),
                      Text(
                        routeName,
                        style: const TextStyle(
                          color: Color(0xFFA3A2A9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          fontFamily: 'SF Pro Text',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.directions_car,
                          size: 16, color: Color(0xFFA3A2A9)),
                      const SizedBox(width: 8),
                      Text(
                        "Vehicle Number: $vehicleNumber",
                        style: const TextStyle(
                          color: Color(0xFFA3A2A9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          fontFamily: 'SF Pro Text',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.people,
                          size: 16, color: Color(0xFFA3A2A9)),
                      const SizedBox(width: 8),
                      Text(
                        'Client Count: $clientCount', // Example target count
                        style: const TextStyle(
                          color: Color(0xFF565656),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.flag,
                          size: 16, color: Color(0xFFA3A2A9)),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Color(0xFFA3A2A9)),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          date,
                          style: const TextStyle(
                            color: Color(0xFFA3A2A9),
                            fontSize: 12,
                            letterSpacing: 1,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
