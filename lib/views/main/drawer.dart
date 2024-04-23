import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: AppColor.primaryTextColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80, left: 30, bottom: 30),
                child: Stack(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 50,
                      child: Text(
                        'JD',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 70,
                      right: 5,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors
                              .green, // Change color based on online/offline status
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: GoogleFonts.getFont(
                          'Poppins',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'johndoe@gmail.com',
                        style: GoogleFonts.getFont(
                          'Poppins',
                          color: const Color(0xA8E5E5E5),
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 30),
                      buildListTile(
                        AppComponents.drawInvIcon,
                        'Inventory',
                        () {
                          // Update UI based on drawer item tap
                        },
                      ),
                      const SizedBox(height: 8),
                      buildListTile(
                        AppComponents.drawReportIcon,
                        'Reports',
                        () {
                          // Update UI based on drawer item tap
                        },
                      ),
                      const SizedBox(height: 8),
                      buildListTile(
                        AppComponents.drawInvoiceIcon,
                        'Invoice',
                        () {
                          // Update UI based on drawer item tap
                        },
                      ),
                      const SizedBox(height: 8),
                      buildListTile(
                        AppComponents.drawPaymentIcon,
                        'Payment',
                        () {
                          // Update UI based on drawer item tap
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildListTile(
                      AppComponents.drawLogoutIcon,
                      'Log out',
                      () {
                        // Update UI based on drawer item tap
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to generate a list tile based on the provided parameters
  Widget buildListTile(String leadingAsset, String title, Function onTap) {
    return InkWell(
      onTap: onTap as void
          Function(), // Cast onTap to the appropriate function type
      child: ListTile(
        leading: SvgPicture.asset(
          leadingAsset,
          width: 45,
          height: 45,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            fontFamily: AppComponents.fontSFProTextBold,
          ),
        ),
      ),
    );
  }
}
