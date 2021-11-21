import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecotoken/logic/profile.dart';
import 'package:ecotoken/utils/extensions.dart';

enum Transport {
  Motorcycle, Walking, Metro, Bus, Bicycle, Car,
}

class Trajectory {
  String id;
  final DateTime finish;
  final double tokens;
  final double carbonEmitted;
  final double carbonSaved;
  final double distance;
  final Duration duration;
  final List<GeoPoint> path;
  final Transport transport;
  final Profile owner;

  Trajectory({
    required this.id,
    required this.finish,
    required this.tokens,
    required this.path,
    required this.distance,
    required this.duration,
    required this.carbonEmitted,
    required this.carbonSaved,
    required this.transport,
    required this.owner,
  });
}