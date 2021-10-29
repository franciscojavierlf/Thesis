import 'package:ecotoken/utils/theme.dart';
import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;

  AuthLayout({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xffeee9b9),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: size.height * 0.1, left: 40, right: 40, bottom: 40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/images/logo.png'),
                Text(
                  'EcoToken',
                  style: TextStyle(
                    color: Palette.D,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 50),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
