import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecotoken/logic/profile.dart';

enum Transport {
  Motorcycle, Walking, Metro, Bus, Bicycle, Car,
}

/// A complete trajectory.
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

  /// A trajectory before being added to the blockchain.
  Trajectory.before({
    required DateTime finish,
    required List<GeoPoint> path,
    required Duration duration,
    required Transport transport,
    required Profile owner,
  }) : this(
    id: '',
    finish: finish,
    tokens: 0,
    path: path,
    distance: 0,
    duration: duration,
    carbonEmitted: 0,
    carbonSaved: 0,
    transport: transport,
    owner: owner,
  );
}
