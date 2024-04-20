import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:order_processing_app/components/alert_dialog.dart';
import 'package:order_processing_app/components/custom_button.dart';
import 'package:order_processing_app/components/custom_text.dart';
import 'package:order_processing_app/components/custom_textfield.dart';
import 'package:order_processing_app/components/custom_title.dart';
import 'package:order_processing_app/views/auth/login.dart';
import 'package:order_processing_app/services/api_service.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/utils/util_functions.dart';
import 'package:pinput/pinput.dart';

class EnterNewPassword extends StatefulWidget {
  const EnterNewPassword({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<EnterNewPassword> createState() => _EnterNewPasswordState();
}

class _EnterNewPasswordState extends State<EnterNewPassword> {
  late int pinCode;
  bool isVerifyButtonEnabled = false;
  bool isChangeButtonEnabled = false;
  bool isLoadingVerify = false;
  bool isLoadingChange = false;

  final passwordController = TextEditingController();
  final reenterPasswordController = TextEditingController();

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
                      "Check your email for verification code, and you can verify.",
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
                        enabled: !isChangeButtonEnabled,
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
                              isVerifyButtonEnabled = true;
                            });
                          } else {
                            Logger().w('Input should be a 4-digit number.');
                            setState(() {
                              isVerifyButtonEnabled = false;
                            });
                          }
                        },
                        onChanged: (pin) {
                          if (pin.length < 4) {
                            setState(() {
                              isVerifyButtonEnabled = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomButton(
                        isLoading: isLoadingVerify,
                        buttonText: "Verify",
                        buttonColor: isVerifyButtonEnabled
                            ? (isChangeButtonEnabled
                                ? AppColor.primaryColor
                                : AppColor.accentColor)
                            : AppColor.primaryColor,
                        onTap: isVerifyButtonEnabled && !isChangeButtonEnabled
                            ? () async {
                                setState(() {
                                  isLoadingVerify = true;
                                });
                                final response =
                                    await APIService.verifyNewPasswordOTP(
                                        widget.email, pinCode);
                                if (response['success']) {
                                  Logger().w('otp verification done!');

                                  setState(() {
                                    isLoadingVerify = false;
                                    isChangeButtonEnabled = true;
                                  });
                                } else {
                                  setState(() {
                                    isLoadingVerify = false;
                                  });
                                  _otpInvalid();
                                }
                              }
                            : () {},
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      IgnorePointer(
                        ignoring: !isChangeButtonEnabled,
                        child: CustomTextField(
                          controller: passwordController,
                          hintText: "Password",
                          svgIcon: AppComponents.passwordIcon,
                          obscure: true,
                          suffix: true,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      IgnorePointer(
                        ignoring: !isChangeButtonEnabled,
                        child: CustomTextField(
                          controller: reenterPasswordController,
                          hintText: "Password",
                          svgIcon: AppComponents.passwordIcon,
                          obscure: true,
                          suffix: true,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomButton(
                        isLoading: isLoadingChange,
                        buttonText: "Change Password",
                        buttonColor: isChangeButtonEnabled
                            ? AppColor.accentColor
                            : AppColor.primaryColor,
                        onTap: isChangeButtonEnabled
                            ? () async {
                                if (validateFiled()) {
                                  setState(() {
                                    isLoadingChange = true;
                                  });
                                  final response =
                                      await APIService.changePassword(
                                          widget.email,
                                          passwordController.text);
                                  Logger().w(widget.email);
                                  Logger().w(passwordController.text);
                                  if (response['success']) {
                                    Logger().w('Change Successful!');
                                    _passwordChangedMessage();
                                    passwordController.clear();
                                    reenterPasswordController.clear();
                                    setState(() {
                                      isLoadingChange = false;
                                    });
                                  } else {
                                    setState(() {
                                      isLoadingChange = false;
                                    });
                                    Logger().w('Error when change!');
                                  }
                                } else {
                                  passwordController.clear();
                                  reenterPasswordController.clear();
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

  void _otpInvalid() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'ERROR',
      desc: 'Please enter correct pin number!',
      btnOkOnPress: () {
        UtilFunctions.navigateTo(context, const Login());
      },
    ).show();
  }

  void _passwordChangedMessage() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'SUCCESS',
      desc: 'Your password changed!',
      btnOkOnPress: () {
        UtilFunctions.navigateTo(context, const Login());
      },
    ).show();
  }

  bool validateFiled() {
    if (reenterPasswordController.text.isEmpty ||
        passwordController.text.isEmpty) {
      AleartBox.showAleart(
          context, DialogType.error, 'ERROR', 'Please fill all fields!');
      return false;
    } else if (passwordController.text.length < 8) {
      AleartBox.showAleart(context, DialogType.error, 'ERROR',
          'Password must be at least 6 characters long!');
      return false;
    } else if (reenterPasswordController.text != passwordController.text) {
      AleartBox.showAleart(
          context, DialogType.error, 'ERROR', 'Passwords do not match!');
      return false;
    } else {
      return true;
    }
  }
}
