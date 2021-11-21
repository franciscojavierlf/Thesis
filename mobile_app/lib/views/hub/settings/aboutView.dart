import 'package:ecotoken/views/hub/hubLayout.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HubLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child:EcoText.h1('<'),),
              SizedBox(width: 10),
              EcoText.h3('Acerca de'),
            ],
          ),
          SizedBox(height: 15),
          EcoText.p(
              'Creado como proyecto de tesis para las carreras de Ingeniería en Computación y Licenciatura en Matemáticas Aplicadas en el Instituto Tecnológico Autónomo de México (ITAM) por Francisco Javier López Franco.'),
        ],
      ),
    );
  }
}
