import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:order_processing_app/utils/app_colors.dart';
import 'package:order_processing_app/utils/app_components.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    this.svgIcon,
    required this.buttonText,
    required this.onTap,
    this.buttonColor = AppColor.accentColor,
    this.isLoading = false,
  });

  final String? svgIcon;
  final String buttonText;
  final Function() onTap;
  final Color buttonColor;
  final bool isLoading;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isLoading,
      child: SizedBox(
        width: double.infinity,
        child: MouseRegion(
          onEnter: (event) => setState(() => isHovered = true),
          onExit: (event) => setState(() => isHovered = false),
          child: ElevatedButton.icon(
            onPressed: widget.onTap,
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return widget.buttonColor
                      .withOpacity(0.5); // Adjust opacity for disabled state
                } else if (isHovered) {
                  return AppColor.howerBtnColor;
                } else {
                  return widget.buttonColor;
                }
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  side: const BorderSide(color: AppColor.accentStrokeColor),
                ),
              ),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            icon: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColor.secondaryTextColorLight,
                    ),
                  )
                : (widget.svgIcon != null
                    ? SvgPicture.asset(
                        widget.svgIcon!,
                        width: 24,
                        height: 24,
                      )
                    : const SizedBox()),
            label: widget.isLoading
                ? const SizedBox.shrink() // Hide label when loading
                : Text(
                    widget.buttonText,
                    style: TextStyle(
                      color: AppColor.secondaryTextColorLight,
                      fontSize: 24,
                      fontFamily: AppComponents.fontSFProTextBold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
