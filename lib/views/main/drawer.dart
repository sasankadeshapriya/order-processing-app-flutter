import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_processing_app/services/token_manager.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/views/auth/login.dart';
import 'package:order_processing_app/views/clients/client_list.dart';
import 'package:order_processing_app/views/employee/employee_update_form.dart';
import 'package:order_processing_app/views/inventory/product_list.dart';
import 'package:order_processing_app/views/invoice/invoicePage.dart';
import 'package:order_processing_app/views/invoice/invoice_list_page.dart';
import 'package:order_processing_app/views/reports/emp_sales_report.dart';
import 'package:order_processing_app/views/reports/salesreport.dart';

import '../clients/client_form.dart';
import '../payments/payment_list.dart';

enum DrawerMenu { none, client, invoice, inventory, reports, payment }

class AppDrawer extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userProfilePic;
  final Color connectionStatusColor; // This color will be passed from outside

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userProfilePic,
    required this.connectionStatusColor,
  });

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
              padding: const EdgeInsets.only(top: 80, left: 30, bottom: 20),
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 50,
                    backgroundImage: widget.userProfilePic.isNotEmpty
                        ? NetworkImage(widget.userProfilePic)
                        : null,
                    child: widget.userProfilePic.isEmpty
                        ? Text(
                      widget.userName.isNotEmpty
                          ? widget.userName[0].toUpperCase()
                          : "", // Get the first letter if the name is not empty
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )
                        : null, // No child text when the image is available
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmployeeUpdate(),
                          ),
                        );
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(1), Colors.white.withOpacity(0.5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(Icons.edit, color: AppColor.primaryColor, size: 20),
                        ),
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
                    widget.userName, // Dynamic user name
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.userEmail, // Dynamic user email
                    style: GoogleFonts.poppins(
                      color: const Color(0xA8E5E5E5),
                      fontSize: 14,
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
                            builder: (context) => const ProductList(),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildExpandableTile(
                    AppComponents.drawReportIcon,
                    'Reports',
                    DrawerMenu.reports,
                    [
                      buildSubMenuItem('Sales Report', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SalesReport(),
                          ),
                        );
                      }),
                      buildSubMenuItem('Cash/Credit Sales', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmpSalesReport(),
                          ),
                        );
                      }),
                    ],
                  ),
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
                            builder: (context) => const InvoicePage(),
                          ),
                        );
                      }),
                      buildSubMenuItem('View Invoices', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InvoiceList(),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildExpandableTile(
                    AppComponents.drawPaymentIcon,
                    'Payment',
                    DrawerMenu.payment,
                    [
                      buildSubMenuItem('View Payment', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentList(),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildExpandableTile(
                    AppComponents.drawClientIcon,
                    'Client',
                    DrawerMenu.client,
                    [
                      buildSubMenuItem('Add New Client', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClientForm(),
                          ),
                        );
                      }),
                      buildSubMenuItem('Client List', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClientList(),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
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
        borderRadius: BorderRadius.circular(10),
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
            borderRadius: BorderRadius.circular(10),
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
              trailing: isExpanded
                  ? const Icon(Icons.arrow_drop_up, color: Colors.white)
                  : const Icon(Icons.arrow_drop_down, color: Colors.white),
            ),
          ),
        ),
        AnimatedSize(
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 500),
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(left: 1.0, top: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: children.map((widget) {
                      return Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            // Define the action for the tap here.
                          },
                          splashColor: Colors.blue,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.backgroundColor,
                                border: Border.all(color: Colors.white70),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 17.0),
                                child: widget,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Container(),
        ),
      ],
    );
  }

  Widget buildSubMenuItem(String title, Function onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20.0, right: 16.0, bottom: 0),
      title: Text(
        title,
        style: TextStyle(
          color: AppColor.primaryTextColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: AppComponents.fontSFProTextBold,
        ),
      ),
      onTap: () => onTap(),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Log out',
      desc: 'Are you sure you want to log out?',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await TokenManager
            .clearToken(); // Clear user token or any auth-related storage
        _navigateToLogin(context);
      },
      btnCancelText: "Cancel",
      btnOkText: "Yes",
    )..show();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (Route<dynamic> route) =>
          false, // Removes all the routes beneath the pushed route
    );
  }
}
