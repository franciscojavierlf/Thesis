import 'package:ecotoken/logic/trajectory.dart';
import 'package:ecotoken/logic/wallet.dart';
import 'package:ecotoken/server/blockchain/walletsBloc.dart';
import 'package:ecotoken/views/mainController.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';

class HomeController extends GetxController {
  final mainController = Get.find<MainController>();

  final wallet = Rxn<Wallet>();
  final error = false.obs;

  /// Gets the carbon impact of a transport from the authenticated profile.
  double carbonImpact(Transport transport) => wallet.value?.carbonEmitted[transport] ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadWallet();
  }

  void loadWallet() async {
    try {
      wallet(await WalletsBloc.getWallet(mainController.profile!.wallet));
    } catch(ex) {
      print(error);
      error(true);
    }
  }
}