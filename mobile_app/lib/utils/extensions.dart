import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

extension StringExtensions on String {
  String get first => this.split(' ').first;
}

extension DoubleExtensions on double {
  double get asRadians => this * pi / 180;
}

extension GeoPointExtensions on GeoPoint {
  double distance(GeoPoint other) {
    final lat1 = this.latitude.asRadians;
    final lat2 = other.latitude.asRadians;
    final lon1 = this.latitude.asRadians;
    final lon2 = other.latitude.asRadians;

    return 6371 *
        2 *
        asin(sqrt(pow(sin((lat2 - lat1) * 0.5), 2) +
            cos(lat1) * cos(lat2) * pow(sin((lon2 - lon1) * 0.5), 2)));
  }
}

extension DurationExtensions on Duration {
  String get niceString {
    String twoDigitMinutes =  this.inMinutes.remainder(60).toString().padLeft(2, '0');
    String twoDigitSeconds = this.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${this.inHours.toString().padLeft(2, '0')}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

extension DateTimeExtensions on DateTime {
  String get niceString {
    // Chooses month
    String month;
    switch (this.month) {
      case 1:
        month = 'Enero';
        break;
      case 2:
        month = 'Febrero';
        break;
      case 3:
        month = 'Marzo';
        break;
      case 4:
        month = 'Abril';
        break;
      case 5:
        month = 'Mayo';
        break;
      case 6:
        month = 'Junio';
        break;
      case 7:
        month = 'Julio';
        break;
      case 8:
        month = 'Agosto';
        break;
      case 9:
        month = 'Septiembre';
        break;
      case 10:
        month = 'Octubre';
        break;
      case 11:
        month = 'Noviembre';
        break;
      case 12:
      default:
        month = 'Diciembre';
        break;
    }

    return '$month ${this.day}, ${this.year} ${this.hour}:${this.minute.toString().padLeft(2, '0')}';
  }
}
