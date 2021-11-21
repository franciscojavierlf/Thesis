import 'package:ecotoken/logic/profile.dart';
import 'package:ecotoken/logic/wallet.dart';
import 'package:ecotoken/server/blockchain/walletsBloc.dart';
import 'package:ecotoken/server/database/profilesBloc.dart';
import 'package:get/state_manager.dart';

class SocialController extends GetxController {
  final wallets = Rxn<List<Wallet>>();

  @override
  void onInit() {
    super.onInit();
    WalletsBloc.getWallets().then((value) => wallets(value));
  }
}