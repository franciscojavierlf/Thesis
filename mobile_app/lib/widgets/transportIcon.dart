import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/utils/theme.dart';
import 'package:flutter/material.dart';

class TransportIcon extends StatelessWidget {
  final Transport transport;
  final double? size;
  final Color color;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  TransportIcon(
    this.transport, {
    this.size,
    this.padding = EdgeInsets.zero,
    this.color = Palette.D,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    late final IconData data;
    switch (transport) {
      case Transport.Motorcycle:
        data = Icons.motorcycle;
        break;
      case Transport.Walking:
        data = Icons.directions_walk;
        break;
      case Transport.Metro:
        data = Icons.train;
        break;
      case Transport.Bus:
        data = Icons.directions_bus;
        break;
      case Transport.Bicycle:
        data = Icons.pedal_bike;
        break;
      case Transport.Car:
        data = Icons.directions_car;
        break;
    }
    return Container(
      padding: padding,
      decoration: backgroundColor != null ? BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(90),
      ) : null,
      child: Icon(data, color: color, size: size),
    );
  }
}
