import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecotoken/logic/profile.dart';
import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/server/blockchain/restConnection.dart';
import 'package:ecotoken/server/blockchain/walletsBloc.dart';
import 'package:ecotoken/server/database/profilesBloc.dart';
import 'package:ecotoken/utils/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class TrajectoriesBloc {
  static final _db = FirebaseFirestore.instance;

  static Trajectory generateTrajectory({
    required Profile owner,
    required Duration duration,
    required List<GeoPoint> path,
    required Transport transport,
  }) {
    // FOR NOW, IT IS ADDED TO FIREBASE
    // THIS IS WRONG SINCE MANY VARIABLES ARE CALCULATED BY THE SMART CONTRACT
    if (transport == Transport.Car) throw 'Cannot add a trajectory with a car!';
    if (path.length < 2) throw 'Path must contain at least two points!';

    DateTime finish = DateTime.now();
    double distance = 0;
    for (int i = 1; i < path.length; i++)
      distance += path[i - 1].distance(path[i]);

    double carbonEmitted = distance / duration.inMilliseconds * 1000;
    double carbonSaved = distance / duration.inMilliseconds * 1000;
    switch (transport) {
      case Transport.Motorcycle:
        carbonEmitted *= 0.4;
        carbonSaved *= 0.4;
        break;
      case Transport.Metro:
        carbonEmitted *= 1.1;
        carbonSaved *= 1.1;
        break;
      case Transport.Bus:
        carbonEmitted *= 0.9;
        carbonSaved *= 0.9;
        break;
      case Transport.Walking:
      case Transport.Bicycle:
        carbonEmitted *= 1.7;
        carbonSaved *= 1.7;
        break;
      case Transport.Car:
        carbonEmitted *= 0;
        carbonSaved *= 0;
        break;
    }

    final tokens = carbonSaved - carbonEmitted;

    // Creates the trajectory and adds
    return Trajectory(
      id: '',
      carbonEmitted: carbonEmitted,
      carbonSaved: carbonSaved,
      distance: distance,
      duration: duration,
      finish: finish,
      owner: owner,
      path: path,
      tokens: tokens,
      transport: transport,
    );
  }

  static Future<Trajectory> addTrajectory(Trajectory trajectory) async {

    final res = await Future.wait<dynamic>([
      _db.collection('trajectories').add(
            _trajectoryToMap(trajectory),
          ),
      _db.collection('wallets').doc(trajectory.owner.wallet).update({
        'tokens': FieldValue.increment(trajectory.tokens),
        'totalCarbonSaved': FieldValue.increment(trajectory.carbonSaved),
        'totalCarbonEmitted': FieldValue.increment(trajectory.carbonEmitted),
        'totalDistanceTravelled': FieldValue.increment(trajectory.distance),
        'totalTimeTravelled': FieldValue.increment(trajectory.duration.inMilliseconds),
      }),
    ]);
    trajectory.id = res[0].id;

    return trajectory;
  }

  static Future<List<Trajectory>> getTrajectories({Profile? owner}) async {
    final profiles = <String, Profile>{};
    // Gets queries from the owner
    if (owner != null) {
      final List<Map<String, dynamic>> res = await RestConnection.get('/wallets/${owner.wallet}/trajectories');
      print(res);
      return res.map((t) => _trajectoryFromMap(t['_id'], owner, t)).toList();
    }

    return [];

    // final profiles = <String, Profile>{};

    // var query = _db.collection('trajectories');
    // var snapshot;

    // // Gets all trajectories
    // if (owner == null) {
    //   snapshot = await query.orderBy('finish', descending: true).get();

    //   // Gets profiles
    //   final futureProfiles = snapshot.docs
    //       .map((doc) => ProfilesBloc.getProfile(doc.data()['owner']))
    //       .toList();
    //   (await Future.wait(futureProfiles)).forEach(
    //       (profile) => profile != null ? profiles[profile.id] = profile : null);
    // }
    // // Gets of only one owner
    // else {
    //   snapshot = await query.where('owner', isEqualTo: owner.id).orderBy('finish', descending: true).get();
    //   profiles[owner.id] = owner;
    // }

    // final res = <Trajectory>[];
    // snapshot.docs.forEach((doc) => res.add(_trajectoryFromMap(
    //     doc.id, profiles[doc.data()!['owner']]!, doc.data()!)));
  }

  static Map<String, dynamic> _trajectoryToMap(Trajectory trajectory) {
    return {
      'finish': trajectory.finish,
      'tokens': trajectory.tokens,
      'duration': trajectory.duration.inMilliseconds,
      'distance': trajectory.distance,
      'carbonEmitted': trajectory.carbonEmitted,
      'carbonSaved': trajectory.carbonSaved,
      'path': trajectory.path,
      'transport': trajectory.transport.toString(),
      'owner': trajectory.owner.id,
    };
  }

  static Trajectory _trajectoryFromMap(
      String id, Profile owner, Map<String, dynamic> map) {
    return Trajectory(
      id: id,
      finish: map['finish'].toDate(),
      tokens: map['tokens'].toDouble(),
      duration: Duration(milliseconds: map['duration'] ?? 0),
      distance: map['distance'].toDouble(),
      carbonEmitted: map['carbonEmitted'].toDouble(),
      carbonSaved: map['carbonSaved'].toDouble(),
      path: List<GeoPoint>.from(map['path']),
      transport:
          Transport.values.firstWhere((e) => e.toString() == map['transport']),
      owner: owner,
    );
  }
}
