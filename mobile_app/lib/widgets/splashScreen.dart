import 'package:ecotoken/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

/// A Big splash screen for showing a loading animation.
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Palette.midBgColor,
      body: Container(
        alignment: Alignment.center,
        width: 100,
        height: screen.height,
        child: LoadingIndicator(
          indicatorType: Indicator.ballPulse,
          colors: [Palette.A],
          strokeWidth: 1,
          backgroundColor: Colors.transparent,
          pathBackgroundColor: Colors.black,
        ),
      ).centered,
    );
  }
}
