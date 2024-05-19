import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_processing_app/services/token_manager.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/utils/util_functions.dart';
import 'package:order_processing_app/views/auth/login.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.primaryTextColor,
      child: SingleChildScrollView(
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'johndoe@gmail.com',
                    style: GoogleFonts.poppins(
                      color: const Color(0xA8E5E5E5),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildListTile(AppComponents.drawInvIcon, 'Inventory', () {}),
                  const SizedBox(height: 8),
                  buildListTile(AppComponents.drawReportIcon, 'Reports', () {}),
                  const SizedBox(height: 8),
                  buildListTile(
                      AppComponents.drawInvoiceIcon, 'Invoice', () {}),
                  const SizedBox(height: 8),
                  buildListTile(
                      AppComponents.drawPaymentIcon, 'Payment', () {}),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 80),
              child: buildListTile(AppComponents.drawLogoutIcon, 'Log out',
                  () async {
                await _handleLogout(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListTile(String leadingAsset, String title, Function onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        splashColor: Colors.grey.withOpacity(0.3),
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
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    setState(() {});
    await TokenManager.clearToken();
    _navigateToLogin(context);
  }

  void _navigateToLogin(BuildContext context) {
    UtilFunctions.navigateTo(context, const Login());
  }
}
