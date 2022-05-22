import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecotoken/logic/profile.dart';
import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/server/blockchain/restConnection.dart';

abstract class TrajectoriesBloc {

  static Future<Trajectory> addTrajectory(Trajectory trajectory) async {
    final res = await RestConnection.post('/addTrajectory/${trajectory.owner.walletId}', _trajectoryToMap(trajectory));
    return _trajectoryFromMap(res.id,  trajectory.owner, res);
  }

  static Future<List<Trajectory>> getTrajectories(Profile owner) async {
    // Gets queries from the owner
    final List<dynamic> res = await RestConnection.get('/wallets/${owner.walletId}/trajectories');
    return res.map((t) => _trajectoryFromMap(t['id'], owner, t)).toList();
  }

  static Map<String, dynamic> _trajectoryToMap(Trajectory trajectory) {
    return {
      'finish': trajectory.finish.millisecondsSinceEpoch,
      'tokens': trajectory.tokens,
      'duration': trajectory.duration.inMilliseconds,
      'distance': trajectory.distance,
      'carbonEmitted': trajectory.carbonEmitted,
      'carbonSaved': trajectory.carbonSaved,
      'path': trajectory.path.map((point) => [point.latitude, point.longitude]).toList(),
      'transport': trajectory.transport.toString(),
      'owner': trajectory.owner.id,
    };
  }

  static Trajectory _trajectoryFromMap(
      String id, Profile owner, Map<String, dynamic> map) {
    return Trajectory(
      id: id,
      finish: DateTime.fromMillisecondsSinceEpoch(map['finish']),
      tokens: map['tokens'].toDouble(),
      duration: Duration(milliseconds: map['duration'] ?? 0),
      distance: map['distance'].toDouble(),
      carbonEmitted: map['carbonEmitted'].toDouble(),
      carbonSaved: map['carbonSaved'].toDouble(),
      path: (map['path'] as List).map((points) => GeoPoint(points[0], points[1])).toList(),
      transport:
          Transport.values.firstWhere((e) => e.toString() == map['transport']),
      owner: owner,
    );
  }
}
