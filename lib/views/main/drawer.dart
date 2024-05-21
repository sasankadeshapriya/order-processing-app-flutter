import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_processing_app/services/token_manager.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/utils/util_functions.dart';
import 'package:order_processing_app/views/auth/login.dart';
import 'package:order_processing_app/views/invoice/invoicePage.dart';

import '../clients/client_list.dart';
import '../inventory/product_list.dart';
import '../invoice/invoice_list_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  DrawerMenu _expandedMenu = DrawerMenu.none;

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
                  buildExpandableTile(
                    AppComponents.drawInvIcon,
                    'Inventory',
                    DrawerMenu.inventory,
                    [
                      buildSubMenuItem('View Inventory', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductList(),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildListTile(AppComponents.drawReportIcon, 'Reports', () {}),
                  const SizedBox(height: 8),
                  buildExpandableTile(
                    AppComponents.drawInvoiceIcon,
                    'Invoice',
                    DrawerMenu.invoice,
                    [
                      buildSubMenuItem('Add New Invoice', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoicePage(),
                          ),
                        );
                      }),
                      buildSubMenuItem('View Invoices', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoiceList(),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildListTile(
                      AppComponents.drawPaymentIcon, 'Payment', () {}),
                  const SizedBox(height: 8),
                  buildExpandableTile(
                    AppComponents.drawPaymentIcon,
                    'Client',
                    DrawerMenu.client,
                    [
                      buildSubMenuItem('Add New Client', () {
                        // Navigate to Add New Client
                      }),
                      buildSubMenuItem('Client List', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientList(),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
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

  Widget buildExpandableTile(String leadingAsset, String title, DrawerMenu menu,
      List<Widget> children) {
    final isExpanded = _expandedMenu == menu;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _expandedMenu = isExpanded ? DrawerMenu.none : menu;
              });
            },
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
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 13.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: children.map((widget) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.primaryTextColor,
                      border: Border.all(color: Colors.white70),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 17.0),
                      child: widget,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget buildSubMenuItem(String title, Function onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 50.0, right: 16.0, bottom: 0),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: AppComponents.fontSFProTextBold,
        ),
      ),
      onTap: () => onTap(),
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

enum DrawerMenu { none, client, invoice, inventory }
