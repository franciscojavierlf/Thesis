import 'package:ecotoken/logic/profile.dart';
import 'package:ecotoken/logic/trajectory.dart';

class Wallet {
  /// The owner of the wallet.
  final Profile owner;

  /// The tokens that this wallet has.
  final double tokens;

  /// The carbon that has been used for transportation.
  final Map<Transport, double> carbonEmitted;

  /// The carbon that has been saved relative to a standard car.
  final Map<Transport, double> carbonSaved;

  /// Total time travelled.
  final Map<Transport, Duration> timeTravelled;

  /// Total distance travelled.
  final Map<Transport, double> distanceTravelled;

  final double totalDistanceTravelled;
  final double totalCarbonSaved;
  final double totalCarbonEmitted;
  final Duration totalTimeTravelled;


  Wallet({
    required this.owner,
    required this.tokens,
    required this.carbonEmitted,
    required this.carbonSaved,
    required this.timeTravelled,
    required this.distanceTravelled,
    required this.totalCarbonEmitted,
    required this.totalCarbonSaved,
    required this.totalDistanceTravelled,
    required this.totalTimeTravelled,
  });

  /// The transport that the user has taken the most time with.
  Transport get preferredTransport {
    Transport best = Transport.Walking;
    int maxDuration = 0;
    timeTravelled.forEach((key, value) {
      if (value.inMilliseconds > maxDuration) {
        maxDuration = value.inMilliseconds;
        best = key;
      }
    });
    return best;
  }
}
