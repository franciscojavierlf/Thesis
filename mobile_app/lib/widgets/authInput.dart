import 'package:ecotoken/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthInput extends StatelessWidget {
  final Widget? icon;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  AuthInput({
    this.icon,
    this.controller,
    this.validator,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
  });

  final border = OutlineInputBorder(
    borderSide: BorderSide(color: Palette.E, width: 2),
    borderRadius: BorderRadius.circular(90),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      textAlignVertical: TextAlignVertical.top,
      cursorColor: Palette.E,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Palette.D,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        prefixIcon: icon,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Palette.C),
        border: border,
        focusedBorder: border,
        enabledBorder: border,
        errorBorder: border,
        disabledBorder: border,
      ),
    );
  }
}
