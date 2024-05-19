import 'package:flutter/material.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';

class CustomTitle extends StatelessWidget {
  const CustomTitle({
    super.key,
    required this.text,
    this.textAlign = TextAlign.left,
    this.fontSize = 22,
    this.fontWeight,
    this.color = AppColor.primaryTextColor,
  });

  final String text;
  final TextAlign textAlign;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: AppComponents.fontSFProTextBold,
      ),
    );
  }
}
