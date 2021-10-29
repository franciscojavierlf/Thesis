import 'package:ecotoken/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget child;

  CustomButton({
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
      style: ButtonStyle(
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(90))),
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20, horizontal: 40)),
        backgroundColor: MaterialStateProperty.all(Palette.D),
        textStyle: MaterialStateProperty.all(TextStyle(color: Colors.white)),
      ),
    );
  }
}
