import 'package:flutter/material.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.textAlign = TextAlign.left,
    this.fontSize = 12,
    this.fontWeight,
    this.color = AppColor.paragraphTextColor,
  });

  final String text;
  final TextAlign textAlign;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: AppComponents.fontSFProTextSemibold,
      ),
    );
  }
}
