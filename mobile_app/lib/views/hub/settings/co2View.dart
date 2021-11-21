import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/hub/hubLayout.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CO2View extends StatelessWidget {
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
              EcoText.h3('¿Cómo se calcula el $CO2?'),
            ],
          ),
          SizedBox(height: 15),
          EcoText.p(
              'Para poder obtener el $CO2 ahorrado se saca el promedio de $CO2 emitido por transporte, y al obtener la distancia recorrida se puede sacar una estimación de lo que se hubiera gastado.'),
        ],
      ),
    );
  }
}
