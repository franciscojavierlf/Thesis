import 'package:ecotoken/views/hub/hubLayout.dart';
import 'package:ecotoken/views/hub/settings/aboutView.dart';
import 'package:ecotoken/views/hub/settings/co2View.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/hub/settingsController.dart';
import 'package:ecotoken/views/mainController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends StatelessWidget {
  final mainController = Get.find<MainController>();
  final controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return HubLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EcoText.h2('Cuenta'),
          SizedBox(height: 10),
          // List of options
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                title: EcoText.h4('¿Cómo se calcula el $CO2?'),
                tileColor: Colors.white,
                onTap: () => Get.to(CO2View()),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Palette.lightBgColor),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
              ),
              ListTile(
                title: EcoText.h4('Acerca de'),
                tileColor: Colors.white,
                onTap: () => Get.to(AboutView()),
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Palette.D),
                title: EcoText.h4('Cerrar sesión'),
                horizontalTitleGap: -5,
                onTap: () => FirebaseAuth.instance.signOut(),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Palette.lightBgColor),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          EcoText.p('EcoToken').centered,
          EcoText.p('Versión 0.1').centered,
        ],
      ),
    );
  }
}
