import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:order_processing_app/components/alert_dialog.dart';
import 'package:order_processing_app/services/auth_api_service.dart';
import 'package:order_processing_app/views/auth/forgot_password.dart';
import 'package:order_processing_app/components/custom_button.dart';
import 'package:order_processing_app/components/custom_text.dart';
import 'package:order_processing_app/components/custom_textfield.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';
import 'package:order_processing_app/utils/util_functions.dart';
import 'package:order_processing_app/views/auth/otp_verification.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;

  final passwordController = TextEditingController();
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 100,
                ),
                SvgPicture.asset(
                  AppComponents.login,
                  width: 180,
                  height: 180,
                ),
                const SizedBox(
                  height: 21,
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 65,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 18,
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
                        hintText: "Email",
                        svgIcon: AppComponents.emailIcon,
                        controller: emailController,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomTextField(
                        controller: passwordController,
                        hintText: "Password",
                        svgIcon: AppComponents.passwordIcon,
                        obscure: true,
                        suffix: true,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () => UtilFunctions.navigateTo(
                            context,
                            const ForgotPassword(),
                          ),
                          child: const CustomText(
                            text: "Forgot password?",
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 13,
                      ),
                      CustomButton(
                        isLoading: isLoading,
                        buttonText: "Login",
                        onTap: () async {
                          if (validateFiled()) {
                            setState(() {
                              isLoading = true;
                            });
                            final response = await APIService.login(
                                emailController.text, passwordController.text);
                            if (response['success']) {
                              // Login successful, proceed with OTP verification
                              final String email = response['email'];
                              Logger().w(email);
                              _navigateToCodeVerification(email);

                              emailController.clear();
                              passwordController.clear();

                              setState(() {
                                isLoading = false;
                              });
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              _passwordInvalid();
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 50,
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

  void _navigateToCodeVerification(String email) {
    UtilFunctions.navigateTo(context, CodeVerification(email: email));
  }

  void _passwordInvalid() {
    AleartBox.showAleart(
        context, DialogType.error, 'ERROR', 'Please enter correct password!');
  }

  bool validateFiled() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      AleartBox.showAleart(
          context, DialogType.error, 'ERROR', 'Please fill all fields!');
      return false;
    } else if (!emailController.text.contains('@')) {
      AleartBox.showAleart(context, DialogType.error, 'ERROR',
          'Please enter valid email address!');
      return false;
    } else if (passwordController.text.length < 6) {
      AleartBox.showAleart(context, DialogType.error, 'ERROR',
          'Please enter valid email address!');
      return false;
    } else {
      return true;
    }
  }
}
