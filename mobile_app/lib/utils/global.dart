
import 'package:ecotoken/logic/profile.dart';
import 'package:ecotoken/server/blockchain/restConnection.dart';
import 'package:ecotoken/server/database/profilesBloc.dart';
import 'package:ecotoken/utils/functions.dart';
import 'package:ecotoken/views/auth/loginView.dart';
import 'package:ecotoken/views/hub/hubView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Global variables because using redux is too much for the app.

class Global {
  Global._();
  
  static Profile? _profile = null;
  static Profile? get profile => _profile;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Initializes the global variables.
  static void init() {
    // Initializes data for rest connection
    RestConnection.init();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null)
        ProfilesBloc.getProfile(user.uid).then((value) {
          _profile = value;
          goto(navigatorKey.currentContext!, HubView(0), replace: true);
        }).catchError((err) {
          print(err);
        });
      else goto(navigatorKey.currentContext!, LoginView(), replace: true);
    });
  }
}