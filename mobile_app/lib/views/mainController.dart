import 'package:ecotoken/logic/profile.dart';
import 'package:ecotoken/server/database/profilesBloc.dart';
import 'package:ecotoken/views/auth/loginView.dart';
import 'package:ecotoken/views/hub/hubView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';

/// The main controller of the whole application.
class MainController extends GetxController {
  final rxProfile = Rxn<Profile>();

  Profile? get profile => rxProfile.value;

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null)
        ProfilesBloc.getProfile(user.uid).then((value) {
          rxProfile(value);
          Get.offAll(HubView(0));
        }).catchError((err) {
          print(err);
        });
      else Get.offAll(LoginView());
    });
  }
}
