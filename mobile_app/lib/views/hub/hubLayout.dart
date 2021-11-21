import 'package:ecotoken/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';

class HubLayout extends StatelessWidget {
  final Widget body;

  HubLayout({
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.lightBgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: body.paddingAll(25),
          ),
        ),
      ),
    );
  }
}
