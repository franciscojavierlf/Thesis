import 'package:ecotoken/logic/profile.dart';
import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/logic/wallet.dart';
import 'package:ecotoken/server/blockchain/restConnection.dart';
import 'package:ecotoken/server/database/profilesBloc.dart';

class WalletsBloc {
  
  static Future<Wallet> getWallet(String walletId) async {
    final Map<String, dynamic> res = await RestConnection.get('/wallets/${walletId}');
    final owner = await ProfilesBloc.getProfile(walletId: walletId);
    return _walletfromMap(walletId, owner!, res);
  }

  static Future<List<Wallet>> getWallets() async {
    // Gets all wallets
    final List<dynamic> res = await RestConnection.get('/wallets');
    // Loads all the profiles
    final Map<String, Profile> profiles = {};
    final futureProfiles = res.map((wallet) =>
      ProfilesBloc.getProfile(walletId: wallet['id'])
    ).toList();
    (await Future.wait(futureProfiles)).forEach(
        (profile) => profile != null ? profiles[profile.walletId] = profile : null);

    return res.map((wallet) =>
      _walletfromMap(wallet['id'], profiles[wallet['id']]!, wallet))
        .toList();
  }

  static Wallet _walletfromMap(
      String id, Profile owner, Map<String, dynamic> map) {
    final Map<Transport, double>
        carbonSaved = {},
        carbonEmitted = {},
        distanceTravelled = {};
    final Map<Transport, Duration> timeTravelled = {};
    (map['carbonSaved'] ?? {}).forEach((key, value) =>
        carbonSaved[Transport.values.firstWhere((e) => e.toString() == key)] =
            value);
    (map['carbonEmitted'] ?? {}).forEach((key, value) =>
        carbonEmitted[Transport.values.firstWhere((e) => e.toString() == key)] =
            value);
    (map['distanceTravelled'] ?? {}).forEach((key, value) => distanceTravelled[
        Transport.values.firstWhere((e) => e.toString() == key)] = value);
    (map['timeTravelled'] ?? {}).forEach((key, value) =>
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
