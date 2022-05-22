import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecotoken/logic/profile.dart';

abstract class ProfilesBloc {
  static final _db = FirebaseFirestore.instance;

  static Future<Profile?> getProfile({String? uid, String? walletId}) async {
    DocumentSnapshot snapshot;
    if (uid != null)
      snapshot = await _db.collection('profiles').doc(uid).get();
    else if (walletId != null)
      snapshot = (await _db.collection('profiles').where('wallet', isEqualTo: walletId).get()).docs[0];
    else throw 'Invalid arguments.';
    return _profileFromMap(snapshot.id, snapshot.data()! as Map<String, dynamic>);
  }

  static Profile _profileFromMap(String id, Map<String, dynamic> map) {
    return Profile(
      id: id,
      name: map['name'],
      walletId: map['wallet'],
    );
  }
}
