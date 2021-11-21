import 'package:ecotoken/views/auth/loginView.dart';
import 'package:ecotoken/views/mainController.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inititializations
  await Future.wait([
    Firebase.initializeApp(),
  ]);

  Get.put(MainController());
  runApp(EcoToken());
}

class EcoToken extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EcoToken',
      home: LoginView(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
      ),
    );
  }
}
