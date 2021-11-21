import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:ecotoken/widgets/ecoText.dart';
import 'package:ecotoken/widgets/transportIcon.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';

class TransportsTable extends StatelessWidget {
  double? motorcycle;
  double? metro;
  double? bus;
  double? walking;
  double? bicycle;

  TransportsTable({
    this.motorcycle,
    this.metro,
    this.bus,
    this.walking,
    this.bicycle,
  });

  final leftColumnPadding = 20.0;
  final rightColumnPadding = 30.0;

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        if (motorcycle != null)
          TableRow(
            children: [
              TableCell(
                  child: EcoText.pIcon('Motocicleta',
                          TransportIcon(Transport.Motorcycle, size: 16),
                          end: true)
                      .align(Alignment.centerRight)
                      .paddingOnly(right: leftColumnPadding)),
              TableCell(
                  child: EcoText.p('${motorcycle!.toStringAsFixed(2)}kg')
                      .paddingOnly(left: rightColumnPadding)),
            ],
          ),
        if (metro != null)
          TableRow(
            children: [
              TableCell(
                  child: EcoText.pIcon(
                          'Metro', TransportIcon(Transport.Metro, size: 16),
                          end: true)
                      .align(Alignment.centerRight)
                      .paddingOnly(right: leftColumnPadding)),
              TableCell(
                  child: EcoText.p('${metro!.toStringAsFixed(2)}kg')
                      .paddingOnly(left: rightColumnPadding)),
            ],
          ),
        if (bus != null)
          TableRow(
            children: [
              TableCell(
                  child: EcoText.pIcon(
                          'Autobús', TransportIcon(Transport.Bus, size: 16),
                          end: true)
                      .align(Alignment.centerRight)
                      .paddingOnly(right: leftColumnPadding)),
              TableCell(
                  child: EcoText.p('${bus!.toStringAsFixed(2)}kg')
                      .paddingOnly(left: rightColumnPadding)),
            ],
          ),
        if (walking != null)
          TableRow(
            children: [
              TableCell(
                  child: EcoText.pIcon('Caminata',
                          TransportIcon(Transport.Walking, size: 16),
                          end: true)
                      .align(Alignment.centerRight)
                      .paddingOnly(right: leftColumnPadding)),
              TableCell(
                  child: EcoText.p('${walking!.toStringAsFixed(2)}kg')
                      .paddingOnly(left: rightColumnPadding)),
            ],
          ),
        if (bicycle != null)
          TableRow(
            children: [
              TableCell(
                  child: EcoText.pIcon('Bicicleta',
                          TransportIcon(Transport.Bicycle, size: 16),
                          end: true)
                      .align(Alignment.centerRight)
                      .paddingOnly(right: leftColumnPadding)),
              TableCell(
                  child: EcoText.p('${bicycle!.toStringAsFixed(2)}kg')
                      .paddingOnly(left: rightColumnPadding)),
            ],
          ),
      ],
    );
  }
}
