import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:order_processing_app/utils/app_components.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 86, 86, 86),
      body: Center(
        child: Column(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth <= 1000) {
                return SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Image.asset(
                    AppComponents.mapImage,
                    fit: BoxFit.fitHeight,
                  ),
                );
              } else {
                return SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Image.asset(
                    AppComponents.mapImage,
                    fit: BoxFit.contain,
                  ),
                );
              }
            }),
            const SizedBox(
              height: 50,
            ),
            JumpingDots(
              color: Colors.white,
              radius: 8,
              numberOfDots: 4,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Loading...',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
