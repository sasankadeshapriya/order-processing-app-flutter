import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscure = false,
    this.suffix = false,
    required this.svgIcon,
  });

  final String hintText;
  final TextEditingController controller;
  final bool obscure;
  final bool suffix;
  final String svgIcon;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColor.widgetBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: const Color(0xff022E33).withOpacity(.2),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 5,
            ),
            child: SvgPicture.asset(
              widget.svgIcon,
            ),
          ),
          suffixIcon: widget.suffix
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  child: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColor.svgIconColor,
                  ),
                )
              : null,
          hintText: widget.hintText,
          hintStyle: TextStyle(
              color: AppColor.placeholderTextColor.withOpacity(0.5),
              fontFamily: AppComponents.fontSFProTextSemibold,
              fontSize: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColor.fieldStrock),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColor.fieldStrockWarn),
          ),
        ),
      ),
    );
  }
}
