import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecotoken/logic/profile.dart';

abstract class ProfilesBloc {
  static final _db = FirebaseFirestore.instance;

  static Future<Profile?> getProfile(String uid) async {
    if (uid.isEmpty) throw 'Profile uid must not be null.';
    final snapshot = await _db.collection('profiles').doc(uid).get();
    if (!snapshot.exists) throw 'There is no profile with uid $uid.';
    return _profileFromMap(snapshot.id, snapshot.data()!);
  }

  static Profile _profileFromMap(String id, Map<String, dynamic> map) {
    return Profile(
      id: id,
      name: map['name'],
      wallet: map['wallet'],
    );
  }
}
