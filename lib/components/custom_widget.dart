import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String? hintText;
  final String? prefixText;
  final String? labelText;
  final String? suffixText;
  final String? initialValue;
  final bool autofocus;
  final bool readOnly;
  final TextAlign textAlign;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final void Function(String?)? onSaved;
  final VoidCallback? onAddPressed;
  final String buttonText;
  final Color buttonBackgroundColor;
  final Color buttonTextColor;
  final Color buttonStrokeColor;
  final double buttonBorderRadius;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool showPrefixIcon;
  final bool showBorder;
  final bool obscure;
  final bool showVisibilityIcon;
  final VoidCallback? onSuffixIconTap;

  // New parameter to control visibility icon

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.labelText,
    this.prefixText,
    this.suffixText,
    this.suffixIcon,
    this.prefixIcon,
    this.autofocus = false,
    this.readOnly = false,
    this.textAlign = TextAlign.right,
    this.validator,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onSaved,
    this.onAddPressed,
    this.buttonText = 'Add',
    this.buttonBackgroundColor = const Color(0xFFC8B400),
    this.buttonTextColor = const Color(0xFFFFFFFF),
    this.buttonStrokeColor = const Color(0xFFFFE81D),
    this.buttonBorderRadius = 25.0,
    this.showBorder = true,
    this.obscure = false,
    this.showVisibilityIcon = false,
    this.initialValue, // Initialize showVisibilityIcon
    this.showPrefixIcon = false,
    this.onSuffixIconTap,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool obscureText;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    obscureText = widget.obscure;
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          controller: _controller,
          initialValue: widget.initialValue,
          obscureText: obscureText,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          textAlign: widget.textAlign,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            suffixText: widget.suffixText,
            hintText: widget.hintText,
            labelText: widget.labelText,
            //labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            prefixText: widget.prefixText,
            prefixIcon: widget.showPrefixIcon ? widget.prefixIcon : null,
            suffixIcon: widget.onSuffixIconTap != null
                ? GestureDetector(
                    onTap: widget.onSuffixIconTap,
                    child: widget.suffixIcon,
                  )
                : widget.suffixIcon,
            // Show custom suffix icon if visibility icon is not requested
            border: widget.showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )
                : InputBorder.none,
          ),
          validator: widget.validator,
          onSaved: widget.onSaved,
        ),
        if (widget.onAddPressed != null)
          Positioned(
            right: 5,
            child: CustomAddButton(
              // Using CustomAddButton widget
              onPressed: widget.onAddPressed!,
              buttonText: widget.buttonText,
              backgroundColor: widget.buttonBackgroundColor,
              textColor: widget.buttonTextColor,
              strokeColor: widget.buttonStrokeColor,
              borderRadius: widget.buttonBorderRadius,
            ),
          ),
      ],
    );
  }
}

class CustomAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color backgroundColor;
  final Color textColor;
  final Color strokeColor;
  final double borderRadius;

  const CustomAddButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    required this.backgroundColor,
    required this.textColor,
    required this.strokeColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        foregroundColor: MaterialStateProperty.all<Color>(textColor),
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return strokeColor.withOpacity(0.2); // Adjust opacity as needed
            }
            return Colors.transparent; // No overlay color
          },
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: strokeColor), // Border color
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(buttonText),
    );
  }
}

class CustomDropdownButton extends StatelessWidget {
  const CustomDropdownButton({
    super.key,
    required this.hint,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    this.selectedItemBuilder,
    this.hintAlignment,
    this.valueAlignment,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonPadding,
    this.buttonDecoration,
    this.buttonElevation,
    this.icon,
    this.iconSize,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.itemHeight,
    this.itemPadding,
    this.dropdownHeight,
    this.dropdownWidth,
    this.dropdownPadding,
    this.dropdownDecoration,
    this.dropdownElevation,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    this.offset = Offset.zero,
  });

  final String hint;
  final String? value;
  final List<String> dropdownItems;
  final ValueChanged<String?>? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final Alignment? hintAlignment;
  final Alignment? valueAlignment;
  final double? buttonHeight;
  final double? buttonWidth;
  final EdgeInsetsGeometry? buttonPadding;
  final BoxDecoration? buttonDecoration;
  final int? buttonElevation;
  final Widget? icon;
  final double? iconSize;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final double? itemHeight;
  final EdgeInsetsGeometry? itemPadding;
  final double? dropdownHeight;
  final double? dropdownWidth;
  final EdgeInsetsGeometry? dropdownPadding;
  final BoxDecoration? dropdownDecoration;
  final int? dropdownElevation;
  final Radius? scrollbarRadius;
  final double? scrollbarThickness;
  final bool? scrollbarAlwaysShow;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Container(
          alignment: hintAlignment,
          child: Text(
            hint,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        value: value,
        items: dropdownItems
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    alignment: valueAlignment,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        selectedItemBuilder: selectedItemBuilder,
        buttonStyleData: ButtonStyleData(
          height: buttonHeight ?? 60,
          width: buttonWidth ?? 540,
          padding: buttonPadding ?? const EdgeInsets.only(left: 14, right: 14),
          decoration: buttonDecoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.black45,
                ),
              ),
          elevation: buttonElevation ?? 0,
        ),
        iconStyleData: IconStyleData(
          icon: icon ?? const Icon(Icons.arrow_drop_down),
          iconSize: iconSize ?? 30,
          iconEnabledColor: iconEnabledColor,
          iconDisabledColor: iconDisabledColor,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: dropdownHeight ?? 100,
          width: dropdownWidth ?? 373,
          padding: dropdownPadding,
          decoration: dropdownDecoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
          elevation: dropdownElevation ?? 8,
          offset: offset,
          scrollbarTheme: ScrollbarThemeData(
            radius: scrollbarRadius ?? const Radius.circular(40),
            // thickness: scrollbarThickness,
            // thumbVisibility: scrollbarAlwaysShow,
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: itemHeight ?? 40,
          padding: itemPadding ?? const EdgeInsets.only(left: 14, right: 14),
        ),
      ),
    );
  }
}
