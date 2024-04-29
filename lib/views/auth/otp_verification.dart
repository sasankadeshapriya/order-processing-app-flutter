import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:order_processing_app/components/alert_dialog.dart';
import 'package:order_processing_app/components/custom_button.dart';
import 'package:order_processing_app/components/custom_text.dart';
import 'package:order_processing_app/components/custom_title.dart';
import 'package:order_processing_app/services/token_manager.dart';
import 'package:order_processing_app/views/auth/login.dart';
import 'package:order_processing_app/views/main/dashboard.dart';
import 'package:order_processing_app/services/auth_api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/utils/util_functions.dart';
import 'package:pinput/pinput.dart';

class CodeVerification extends StatefulWidget {
  const CodeVerification({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<CodeVerification> createState() => _CodeVerificationState();
}

class _CodeVerificationState extends State<CodeVerification> {
  late int pinCode;
  bool isButtonEnabled = false;
  bool isLoading = false;
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
                  text: "Code Verification",
                ),
                const SizedBox(
                  height: 8,
                ),
                const CustomText(
                  text:
                      "Check your email for verification code, and you can continue.",
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 39,
                  ),
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 16,
                    right: 16,
                    bottom: 24,
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
                      Pinput(
                        defaultPinTheme: PinTheme(
                          width: 67,
                          height: 60,
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: AppColor.placeholderTextColor,
                              fontWeight: FontWeight.w600),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromRGBO(234, 239, 243, 1),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 67,
                          height: 60,
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: AppColor.placeholderTextColor,
                              fontWeight: FontWeight.w600),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColor.widgetStroke,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        showCursor: true,
                        onCompleted: (pin) {
                          bool isInteger = int.tryParse(pin) != null;
                          bool hasFourDigits = pin.length == 4;
                          if (isInteger && hasFourDigits) {
                            setState(() {
                              pinCode = int.parse(pin);
                              isButtonEnabled = true;
                            });
                          } else {
                            Logger().w('Input should be a 4-digit number.');
                            setState(() {
                              isButtonEnabled = false;
                            });
                          }
                        },
                        onChanged: (pin) {
                          if (pin.length < 4) {
                            setState(() {
                              isButtonEnabled = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomButton(
                        isLoading: isLoading,
                        buttonText: "Continue",
                        buttonColor: isButtonEnabled
                            ? AppColor.accentColor
                            : AppColor.primaryColor,
                        onTap: isButtonEnabled
                            ? () async {
                                setState(() {
                                  isLoading = true;
                                });
                                final response = await APIService.verifyOTP(
                                    widget.email, pinCode);
                                if (response['success']) {
                                  Logger().w('login work!');
                                  final String token = response['token'];
                                  await TokenManager.saveToken(token);
                                  _navigateToDashbord();

                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  _otpInvalid();
                                }
                              }
                            : () {},
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

  void _navigateToDashbord() {
    UtilFunctions.navigateTo(context, const UserDashboard());
  }

  void _otpInvalid() {
    AleartBox.showAleart(
        context, DialogType.error, 'ERROR', 'Please enter correct pin number!');
    UtilFunctions.navigateTo(context, const Login());
  }
}
