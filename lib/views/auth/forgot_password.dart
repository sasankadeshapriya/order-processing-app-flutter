import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:order_processing_app/components/alert_dialog.dart';
import 'package:order_processing_app/components/custom_button.dart';
import 'package:order_processing_app/components/custom_text.dart';
import 'package:order_processing_app/components/custom_textfield.dart';
import 'package:order_processing_app/components/custom_title.dart';
import 'package:order_processing_app/services/api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/utils/util_functions.dart';
import 'package:order_processing_app/views/auth/enter_new_password.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isLoading = false;
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            width: size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 66,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    AppComponents.arrowIcon,
                  ),
                ),
                const SizedBox(
                  height: 46,
                ),
                const CustomTitle(
                  text: "Forgot Password?",
                ),
                const SizedBox(
                  height: 8,
                ),
                const CustomText(
                  text:
                      "If you need help resetting your password, we can help by sending you a link to reset it.",
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 39,
                  ),
                  padding: const EdgeInsets.only(
                    top: 31,
                    left: 12.5,
                    right: 12.5,
                    bottom: 23,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(14),
                    ),
                    color: AppColor.widgetBackgroundColor,
                    border: Border.all(
                      color: AppColor.fieldStrock,
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: emailController,
                        hintText: "Email",
                        svgIcon: AppComponents.emailIcon,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomButton(
                        isLoading: isLoading,
                        buttonText: "Continue",
                        onTap: () async {
                          if (validateFiled()) {
                            setState(() {
                              isLoading = true;
                            });
                            final response =
                                await APIService.sendOTP(emailController.text);
                            if (response['success']) {
                              // OTP sent successfully
                              Logger().w('OTP sent successfully');
                              final String email = response['email'];
                              _navigateToEnterNewPassword(email);
                              emailController.clear();
                              setState(() {
                                isLoading = false;
                              });
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              _emailInvalid();
                              Logger().w('Failed to send OTP');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool validateFiled() {
    if (emailController.text.isEmpty) {
      AleartBox.showAleart(
          context, DialogType.error, 'ERROR', 'Please fill email fields!');
      return false;
    } else if (!emailController.text.contains('@')) {
      AleartBox.showAleart(context, DialogType.error, 'ERROR',
          'Please enter valid email address!');
      return false;
    } else {
      return true;
    }
  }

  void _emailInvalid() {
    AleartBox.showAleart(
        context, DialogType.error, 'ERROR', 'Email nof found!');
  }

  void _navigateToEnterNewPassword(String email) {
    UtilFunctions.navigateTo(context, EnterNewPassword(email: email));
  }
}
