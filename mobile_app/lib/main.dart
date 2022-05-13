import 'package:ecotoken/utils/global.dart';
import 'package:ecotoken/views/auth/loginView.dart';
import 'package:ecotoken/views/mainController.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inititializations
  await Future.wait([
    Firebase.initializeApp(),
  ]);
  Global.init();
  runApp(EcoToken());
}

class EcoToken extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoToken',
      home: LoginView(),
      navigatorKey: Global.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
      ),
    );
  }
}
