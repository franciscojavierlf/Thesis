import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/utils/extensions.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/hub/hubLayout.dart';
import 'package:ecotoken/views/hub/hubView.dart';
import 'package:ecotoken/views/trajectory/trajectoryController.dart';
import 'package:ecotoken/widgets/ecoButton.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrajectoryView extends GetView<TrajectoryController> {
  final bool finished;

  TrajectoryView(Trajectory trajectory) : finished = false {
    Get.put(TrajectoryController(trajectory));
  }

  TrajectoryView.finished(Trajectory trajectory) : finished = true {
    Get.put(TrajectoryController(trajectory));
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return HubLayout(
      scroll: false,
      body: Column(
        children: [
          ListTile(
            leading: TransportIcon(controller.trajectory.transport, size: 50),
            title: EcoText.h3(finished ? 'Recorrido terminado' : 'Recorrido'),
            subtitle: EcoText.p(controller.trajectory.finish.niceString),
          ),
          SizedBox(height: 20),
          // Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  EcoText.h2(controller.trajectory.distance.toStringAsFixed(2)),
                  EcoText.p('km'),
                ],
              ),
              Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  EcoText.h2(controller.trajectory.duration.niceString),
                  EcoText.p('tiempo'),
                ],
              ),
              Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  EcoText.h2(
                      controller.trajectory.carbonEmitted.toStringAsFixed(2)),
                  EcoText.p(CO2),
                ],
              ),
            ],
          ),
          SizedBox(height: 25),

          // C02 saved
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              EcoText.h3('$CO2 ahorrado'),
              Tooltip(
                message:
                    'Cantidad de $CO2 ahorrada si se hubiera usado un coche.',
                triggerMode: TooltipTriggerMode.tap,
                margin: EdgeInsets.symmetric(horizontal: screen.width * 0.15),
                child: EcoText.h4(' (?)'),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Car
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 25,
            children: [
              TransportIcon(Transport.Car),
              EcoText.p(
                  '${controller.trajectory.carbonSaved.toStringAsFixed(2)}kg'),
            ],
          ).expanded,

          // Bottom
          EcoText.p(finished ? 'Has generado' : 'Generaste').centered,
          SizedBox(height: 10),
          EcoText.pIcon(controller.trajectory.tokens.toStringAsFixed(8),
              Image.asset('assets/images/logo.png', width: 30)),
          SizedBox(height: 25),
          if (finished)
            Obx(
              () => controller.loading.value
                  ? EcoText.h4('Cargando...')
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        EcoButton(
                            onPressed: () => Get.offAll(HubView(0)),
                            child: Text('Eliminar')),
                        EcoButton(
                            onPressed: controller.uploadTrajectory,
                            child: Text('Guardar')),
                      ],
                    ),
            )
          else
            EcoButton(onPressed: () => Get.back(), child: Text('Regresar')),
        ],
      ),
    );
  }
}
