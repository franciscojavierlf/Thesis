import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecotoken/logic/profile.dart';
import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/logic/wallet.dart';
import 'package:ecotoken/server/database/profilesBloc.dart';

class WalletsBloc {
  static final _db = FirebaseFirestore.instance;
  
  static Future<Wallet> getWallet(String walletId) async {
    // FOR NOW, IT REACHES FIREBASE. IT SHOULD REACH THE BLOCKCHAIN.
    final snapshot = await _db.collection('wallets').doc(walletId).get();
    if (!snapshot.exists) throw 'Wallet with id $walletId does not exist.';
    // Loads the profile
    final owner = await ProfilesBloc.getProfile(snapshot.data()!['owner']);
    if (owner == null)
      throw 'Owner with id ${snapshot.data()!['owner']} was not found.';
    return _walletfromMap(snapshot.id, owner, snapshot.data()!);
  }

  static Future<List<Wallet>> getWallets() async {
    final snapshot =
        await _db.collection('wallets').orderBy('carbonSaved').get();
    // Loads all the profiles
    final Map<String, Profile> profiles = {};
    final futureProfiles = snapshot.docs
        .map((doc) => ProfilesBloc.getProfile(doc.data()['owner']))
        .toList();
    (await Future.wait(futureProfiles)).forEach(
        (profile) => profile != null ? profiles[profile.id] = profile : null);

    return snapshot.docs
        .map((doc) =>
            _walletfromMap(doc.id, profiles[doc.data()['owner']]!, doc.data()))
        .toList();
  }

  static Wallet _walletfromMap(
      String id, Profile owner, Map<String, dynamic> map) {
    final Map<Transport, double>
        carbonSaved = {},
        carbonEmitted = {},
        distanceTravelled = {};
    final Map<Transport, Duration> timeTravelled = {};
    map['carbonSaved'].forEach((key, value) =>
        carbonSaved[Transport.values.firstWhere((e) => e.toString() == key)] =
            value);
    map['carbonEmitted'].forEach((key, value) =>
        carbonEmitted[Transport.values.firstWhere((e) => e.toString() == key)] =
            value);
    map['distanceTravelled'].forEach((key, value) => distanceTravelled[
        Transport.values.firstWhere((e) => e.toString() == key)] = value);
    map['timeTravelled'].forEach((key, value) =>
        timeTravelled[Transport.values.firstWhere((e) => e.toString() == key)] =
            Duration(seconds: value));

    return Wallet(
      owner: owner,
      tokens: map['tokens']?.toDouble() ?? 0.0,
      carbonSaved: carbonSaved,
      carbonEmitted: carbonEmitted,
      distanceTravelled: distanceTravelled,
      timeTravelled: timeTravelled,
      totalCarbonEmitted: map['totalCarbonEmitted']?.toDouble() ?? 0.0,
      totalCarbonSaved: map['totalCarbonSaved']?.toDouble() ?? 0.0,
      totalDistanceTravelled: map['totalDistanceTravelled']?.toDouble() ?? 0.0,
      totalTimeTravelled: Duration(milliseconds: map['totalTimeTravelled'] ?? 0),
    );
  }
}
