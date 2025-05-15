import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textFieldController;
  final String hintText;
  final bool isObscure;
  final TextInputType textInputType;
  final Widget? prefixIcon;

  const CustomTextField({
    super.key,
    required this.textFieldController,
    required this.hintText,
    this.isObscure = false,
    required this.textInputType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextField(
      controller: textFieldController,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(10),
        prefixIcon: prefixIcon,
      ),
      obscureText: isObscure,
      keyboardType: textInputType,
    );
  }
}
