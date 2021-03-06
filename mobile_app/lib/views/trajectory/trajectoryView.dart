import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/server/blockchain/trajectoriesBloc.dart';
import 'package:ecotoken/utils/extensions.dart';
import 'package:ecotoken/utils/functions.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/views/hub/hubLayout.dart';
import 'package:ecotoken/views/hub/hubView.dart';
import 'package:ecotoken/widgets/ecoButton.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:flutter/material.dart';

class TrajectoryView extends StatefulWidget {
  final Trajectory trajectory;
  final bool finished;

  TrajectoryView(this.trajectory) : finished = false;
  TrajectoryView.finished(this.trajectory) : finished = true;

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TrajectoryView> {
  var loading = false;

  void uploadTrajectory() async {
    setState(() => loading = true);
    try {
      await TrajectoriesBloc.addTrajectory(widget.trajectory);
      setState(() => loading = false);
    } catch (ex) {
      print(ex);
      setState(() => loading = false);
    }
    goto(context, HubView(1), replace: true);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return HubLayout(
      scroll: false,
      body: Column(
        children: [
          ListTile(
            leading: TransportIcon(widget.trajectory.transport, size: 50),
            title: EcoText.h3(
                widget.finished ? 'Recorrido terminado' : 'Recorrido'),
            subtitle: EcoText.p(widget.trajectory.finish.niceString),
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
                  EcoText.h2(widget.trajectory.distance.toStringAsFixed(2)),
                  EcoText.p('km'),
                ],
              ),
              Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  EcoText.h2(widget.trajectory.duration.niceString),
                  EcoText.p('tiempo'),
                ],
              ),
              Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  EcoText.h2(
                      widget.trajectory.carbonEmitted.toStringAsFixed(2)),
                  EcoText.p(CO2),
                ],
              ),
            ],
          ),
          SizedBox(height: 25),

          // C02 saved
          if (!widget.finished)
            Column(
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    EcoText.h3('$CO2 ahorrado'),
                    Tooltip(
                      message:
                          'Cantidad de $CO2 ahorrada si se hubiera usado un coche.',
                      triggerMode: TooltipTriggerMode.tap,
                      margin:
                          EdgeInsets.symmetric(horizontal: screen.width * 0.15),
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
                        '${widget.trajectory.carbonSaved.toStringAsFixed(2)}kg'),
                  ],
                ).expanded,

                // Bottom
                EcoText.p(widget.finished ? 'Has generado' : 'Generaste')
                    .centered,
                SizedBox(height: 10),
                EcoText.pIcon(widget.trajectory.tokens.toStringAsFixed(8),
                    Image.asset('assets/images/logo.png', width: 30)),
                SizedBox(height: 25),
              ],
            ),

          if (widget.finished)
            (loading
                ? EcoText.h4('Cargando...')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      EcoButton(
                          onPressed: () =>
                              goto(context, HubView(0), replace: true),
                          child: Text('Eliminar')),
                      EcoButton(
                          onPressed: uploadTrajectory, child: Text('Guardar')),
                    ],
                  ))
          else
            EcoButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Regresar')),
        ],
      ),
    );
  }
}
